//
//  CurrentTripViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "CurrentTripViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "constants.h"

enum {
    RowLatitude = 0,
    RowLongitude,
    RowAltitude,
    RowCourse,
    RowSpeed,
    RowAvgSpeed,
    RowDistance,
    RowDuration,
    RowPoints,
    RowCount
};

@interface CurrentTripViewController () <CLLocationManagerDelegate> {
    UIBarButtonItem *_monitorButtonItem;
    UIBarButtonItem *_startStopButtonItem;
    CLLocationManager *_locationManager;
    CLLocation *_lastLocation;
    CLLocationDistance _distance;
    BOOL _monitoring;
    BOOL _tracking;
}
@end

@implementation CurrentTripViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Current Trip";
        self.tabBarItem.title = @"Current Trip";
        self.tabBarItem.image = [UIImage imageNamed:@"location"];

        _monitorButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Monitor"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(toggleMonitor)];
        self.navigationItem.leftBarButtonItem = _monitorButtonItem;

        _startStopButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Track"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(toggleTracking)];
        self.navigationItem.rightBarButtonItem = _startStopButtonItem;

        _trip = nil;

        _lastLocation = nil;
        _distance = 0.0;
        _monitoring = NO;
        _tracking = NO;

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_startStopButtonItem release];
    [_trip release];
    [_lastLocation release];
    [_locationManager release];
    [super dealloc];
}

- (void)startMonitoring {
    _monitoring = YES;

    [_locationManager startUpdatingLocation];
    _monitorButtonItem.style = UIBarButtonItemStyleDone;
}

- (void)stopMonitoring {
    _monitoring = NO;

    [_locationManager stopUpdatingLocation];
    _monitorButtonItem.style = UIBarButtonItemStyleBordered;
}

- (void)toggleMonitor {
    if (!_monitoring) {
        [self startMonitoring];
    } else {
        [self stopMonitoring];
    }
}

- (void)startTracking {
    _tracking = YES;

    [_trip release];
    _trip = [[Trip alloc] init];

    _distance = 0.0;

    [self startMonitoring];

    _monitorButtonItem.enabled = NO;

    _startStopButtonItem.style = UIBarButtonItemStyleDone;
}

- (void)stopTracking {
    _tracking = NO;

    // Process the trip
    [AppDelegate processTrip:_trip];

    [self stopMonitoring];

    _monitorButtonItem.enabled = YES;

    _startStopButtonItem.style = UIBarButtonItemStyleBordered;
}

- (void)toggleTracking {
    if (_tracking) {
        [self stopTracking];
    } else {
        [self startTracking];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (indexPath.row) {
        case RowLatitude: {
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.5f", _lastLocation.coordinate.latitude];
            break;
        }

        case RowLongitude: {
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.5f", _lastLocation.coordinate.longitude];
            break;
        }

        case RowAltitude: {
            cell.textLabel.text = @"Altitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.altitude];
            break;
        }

        case RowCourse: {
            cell.textLabel.text = @"Course";

            if (_lastLocation.course != -1) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.course];
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowSpeed: {
            cell.textLabel.text = @"Speed";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MPH", _lastLocation.speed * MPS_TO_MIPH];
            break;
        }

        case RowAvgSpeed: {
            cell.textLabel.text = @"Avg Speed";

            if (_tracking) {
                CLLocation *firstLocation = [_trip firstLocation];
                NSTimeInterval duration = [_lastLocation.timestamp timeIntervalSinceDate:firstLocation.timestamp];

                if (firstLocation == nil || duration < 10.0) {
                    cell.detailTextLabel.text = @"Calculating";
                } else {
                    double avgSpeed = _distance / duration;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MPH", avgSpeed * MPS_TO_MIPH];
                }
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowDistance: {
            cell.textLabel.text = @"Distance";

            if (_tracking) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f mi", _distance * METER_TO_MILES];
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowDuration: {
            cell.textLabel.text = @"Duration";

            if (_tracking) {
                NSInteger duration = (NSInteger)[_trip duration];
                NSInteger hour = duration / 3600;
                NSInteger min = (duration / 60) % 60;
                NSInteger sec = duration % 60;

                cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowPoints: {
            cell.textLabel.text = @"Points";

            if (_tracking) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [_trip.locations count]];
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        default:
            break;
    }

    if (_lastLocation == nil) {
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

#pragma mark - Location manager data source

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];

    if (_tracking) {
        // Add the locations to the trip
        double currentDistance = [_lastLocation distanceFromLocation:currentLocation];
        if (currentDistance > LOCATION_DISTANCE_FILTER || _lastLocation == nil) {
            [_trip addLocation:currentLocation];
        }

        // Update the distance calculation
        _distance += currentDistance;

        // Check if we're in the stop region
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        if ([appDelegate.stopRegion containsCoordinate:currentLocation.coordinate]) {
            [self stopTracking];

            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

            UILocalNotification *localNotification = [[[UILocalNotification alloc] init] autorelease];
            localNotification.alertBody = @"Stop region reached";
            localNotification.soundName = UILocalNotificationDefaultSoundName;

            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
    
    // Update the last location with the current location
    [_lastLocation release];
    _lastLocation = [currentLocation retain];
    
    // Update the table
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end

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
    SectionGps = 0,
    SectionTrip,
    SectionCount
};

enum {
    RowGpsLatitude = 0,
    RowGpsLongitude,
    RowGpsAltitude,
    RowGpsCourse,
    RowGpsSpeed,
    RowGpsHorAcc,
    RowGpsVerAcc,
    RowGpsCount
};

enum {
    RowTripDistance,
    RowTripDuration,
    RowTripAvgSpeed,
    RowTripPoints,
    RowTripCount
};

@interface CurrentTripViewController () <CLLocationManagerDelegate> {
    UIBarButtonItem *_monitorButtonItem;
    UIBarButtonItem *_recordButtonItem;
    CLLocationManager *_locationManager;
    CLLocation *_lastLocation;
    CLLocationDistance _distance;
    BOOL _monitoring;
    BOOL _recording;
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

        _recordButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Record"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(toggleRecord)];
        self.navigationItem.rightBarButtonItem = _recordButtonItem;

        _trip = nil;

        _lastLocation = nil;
        _distance = 0.0;
        _monitoring = NO;
        _recording = NO;

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_recordButtonItem release];
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

- (void)startRecording {
    _recording = YES;

    // Reset the trip
    [_trip release];
    _trip = [[Trip alloc] init];

    _distance = 0.0;

    // Start monitoring location updates
    [self startMonitoring];

    // Update the UI to indicate we're recording
    self.tabBarItem.badgeValue = @" ";
    _monitorButtonItem.enabled = NO;
    _recordButtonItem.tintColor = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f];
}

- (void)stopRecord {
    _recording = NO;

    // Stop monitoring location updates
    [self stopMonitoring];

    // Process the trip
    [AppDelegate processTrip:_trip];

    // Update the UI to indicate we're not recording
    self.tabBarItem.badgeValue = nil;
    _monitorButtonItem.enabled = YES;
    _recordButtonItem.tintColor = nil;
}

- (void)toggleRecord {
    if (_recording) {
        [self stopRecord];
    } else {
        [self startRecording];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionGps:
            return RowGpsCount;

        case SectionTrip:
            return RowTripCount;

        default:
            break;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section)
        case SectionGps: {
            return @"GPS";

        case SectionTrip:
            return @"Trip";

        default:
            break;
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case SectionGps: {
            cell = [self tableView:tableView gpsCellForRow:indexPath.row];
            break;
        }

        case SectionTrip: {
            cell = [self tableView:tableView tripCellForRow:indexPath.row];
            break;
        }

        default:
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView gpsCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"GpsCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (row) {
        case RowGpsLatitude: {
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.5f", _lastLocation.coordinate.latitude];
            break;
        }

        case RowGpsLongitude: {
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.5f", _lastLocation.coordinate.longitude];
            break;
        }

        case RowGpsAltitude: {
            cell.textLabel.text = @"Altitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.altitude];
            break;
        }

        case RowGpsCourse: {
            cell.textLabel.text = @"Course";

            if (_lastLocation.course != -1) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.course];
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowGpsSpeed: {
            cell.textLabel.text = @"Speed";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d MPH", (int)round(_lastLocation.speed * MPS_TO_MIPH)];
            break;
        }

        case RowGpsHorAcc: {
            cell.textLabel.text = @"Hor. Accuracy";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%dm", (int)round(_lastLocation.horizontalAccuracy)];
            break;
        }

        case RowGpsVerAcc: {
            cell.textLabel.text = @"Ver. Accuracy";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%dm", (int)round(_lastLocation.horizontalAccuracy)];
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

- (UITableViewCell *)tableView:(UITableView *)tableView tripCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"TripCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (row) {
        case RowTripDistance: {
            cell.textLabel.text = @"Distance";

            if (_recording) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f mi", _distance * METER_TO_MILES];
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowTripDuration: {
            cell.textLabel.text = @"Duration";

            if (_recording) {
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

        case RowTripAvgSpeed: {
            cell.textLabel.text = @"Avg Speed";

            if (_recording) {
                CLLocation *firstLocation = [_trip firstLocation];
                NSTimeInterval duration = [_lastLocation.timestamp timeIntervalSinceDate:firstLocation.timestamp];

                if (firstLocation == nil || duration < 10.0) {
                    cell.detailTextLabel.text = @"Calculating";
                } else {
                    double avgSpeed = _distance / duration;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d MPH", (int)round(avgSpeed * MPS_TO_MIPH)];
                }
            } else {
                cell.detailTextLabel.text = @"";
            }
            break;
        }

        case RowTripPoints: {
            cell.textLabel.text = @"Points";

            if (_recording) {
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

- (BOOL)isValidLocation:(CLLocation *)location {
    // Check if the location update is current
    if (ABS([location.timestamp timeIntervalSinceNow]) > MAX_LOCATION_AGE) {
        return NO;
    }

    // Check of the location accuracy is good enough
    if (location.horizontalAccuracy > MAX_HORIZONTAL_ACCURACY) {
        return NO;
    }

    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];

    if (_recording && [self isValidLocation:currentLocation]) {
        // Compute the distance travled since the last point
        double currentDistance = [_lastLocation distanceFromLocation:currentLocation];

        // Update the total distance calculation
        _distance += currentDistance;

        // Check if we're in the stop region
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        if ([appDelegate.stopRegion containsCoordinate:currentLocation.coordinate]) {
            // Add the stop point to the trip
            [_trip addLocation:currentLocation];

            // Stop recording
            [self stopRecord];

            // Signal the user that we've stopped by vibrating
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

            // Notify the user that we've stopped tracking
            UILocalNotification *localNotification = [[[UILocalNotification alloc] init] autorelease];
            localNotification.alertBody = @"Stop region reached";
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        } else {
            // Add the point if it's moved enough since the last point
            if (currentDistance > LOCATION_DISTANCE_FILTER || _lastLocation == nil) {
                [_trip addLocation:currentLocation];
            }
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

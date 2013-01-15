//
//  CurrentTripViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "CurrentTripViewController.h"
#import "AppDelegate.h"
#import "constants.h"

enum {
    RowLatitude = 0,
    RowLongitude,
    RowAltitude,
    RowSpeed,
    RowAvgSpeed,
    RowCourse,
    RowDistance,
    RowDuration,
    RowPoints,
    RowCount
};

@interface CurrentTripViewController () <CLLocationManagerDelegate> {
    UIBarButtonItem *_startStopButtonItem;
    CLLocationManager *_locationManager;
    CLLocation *_lastLocation;
    CLLocationDistance _distance;
    BOOL _running;
}
@end

@implementation CurrentTripViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Current Trip";
        self.tabBarItem.title = @"Current Trip";
        self.tabBarItem.image = [UIImage imageNamed:@"location"];

        _startStopButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(toggleStartStop)];
        self.navigationItem.rightBarButtonItem = _startStopButtonItem;

        _trip = nil;

        _lastLocation = nil;
        _distance = 0.0;
        _running = NO;

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.distanceFilter = LOCATION_DISTANCE_FILTER;
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
    _running = YES;

    [_trip release];
    _trip = [[Trip alloc] init];

    [_lastLocation release];
    _lastLocation = nil;
    _distance = 0.0;

    [_locationManager startUpdatingLocation];

    _startStopButtonItem.title = @"Stop";
    _startStopButtonItem.tintColor = [UIColor colorWithRed:0.7f green:0.2f blue:0.2f alpha:1.0f];
}

- (void)stopMonitoring {
    _running = NO;

    [self saveTrip];

    [_locationManager stopUpdatingLocation];

    _startStopButtonItem.title = @"Start";
    _startStopButtonItem.tintColor = nil;
}

- (void)toggleStartStop {
    if (_running) {
        [self stopMonitoring];
    } else {
        [self startMonitoring];
    }
}

- (void)saveTrip {
    // Get the current timestamp for the filename
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = @"yyyyMMdd'T'HHmmss'.xml'";
    NSString *filename = [dateFormatter stringFromDate:[NSDate date]];

    // Create a path for the file in the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];

    // Save the trip to the file
    [NSKeyedArchiver archiveRootObject:_trip toFile:filePath];
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
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.course];
            break;
        }

        case RowSpeed: {
            cell.textLabel.text = @"Speed";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MPH", _lastLocation.speed * MPS_TO_MIPH];
            break;
        }

        case RowAvgSpeed: {
            cell.textLabel.text = @"Avg Speed";

            NSTimeInterval duration = [_lastLocation.timestamp timeIntervalSinceDate:[_trip firstLocation].timestamp];
            if (duration < 10.0) {
                cell.detailTextLabel.text = @"Calculating";
            } else {
                double avgSpeed = _distance / duration;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MPH", avgSpeed * MPS_TO_MIPH];
            }
            break;
        }

        case RowDistance: {
            cell.textLabel.text = @"Distance";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f mi", _distance * METER_TO_MILES];
            break;
        }

        case RowDuration: {
            cell.textLabel.text = @"Duration";

            NSInteger duration = (NSInteger)[_trip duration];
            NSInteger hour = duration / 3600;
            NSInteger min = (duration / 60) % 60;
            NSInteger sec = duration % 60;

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
            break;
        }

        case RowPoints: {
            cell.textLabel.text = @"Points";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [_trip.locations count]];
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
    for (CLLocation *location in locations) {
        [_trip addLocation:location];
    }

    CLLocation *currentLocation = [locations lastObject];
    _distance += [_lastLocation distanceFromLocation:currentLocation];

    [_lastLocation release];
    _lastLocation = [currentLocation retain];

    AppDelegate *appDelegate = [AppDelegate appDelegate];
    if ([appDelegate.stopRegion containsCoordinate:currentLocation.coordinate]) {
        [self stopMonitoring];
    }
    
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end

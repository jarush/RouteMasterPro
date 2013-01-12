//
//  CurrentRouteViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "CurrentRouteViewController.h"

#define MPS_TO_MIPH    2.23694
#define DELTA_DISTANCE 10.0

enum {
    RowLatitude = 0,
    RowLongitude,
    RowAltitude,
    RowSpeed,
    RowCourse,
    RowDuration,
    RowCount
};

@interface CurrentRouteViewController () <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    CLLocation *_lastLocation;
    BOOL _running;
}
@end

@implementation CurrentRouteViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Current";

        _startStopButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(toggleStartStop)] autorelease];
        self.navigationItem.rightBarButtonItem = _startStopButtonItem;

        _route = nil;

        _lastLocation = nil;
        _running = NO;

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.distanceFilter = DELTA_DISTANCE;
        _locationManager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_startStopButtonItem release];
    [_route release];
    [_lastLocation release];
    [_locationManager release];
    [super dealloc];
}

- (void)startMonitoring {
    _running = YES;

    _route = [[Route alloc] init];

    [_locationManager startUpdatingLocation];
	
    self.startStopButtonItem.title = @"Stop";
    self.startStopButtonItem.tintColor = [UIColor colorWithRed:0.7f green:0.2f blue:0.2f alpha:1.0f];
}

- (void)stopMonitoring {
    _running = NO;

    [self saveRoute];
    [_route release];

    [_locationManager stopUpdatingLocation];

    self.startStopButtonItem.title = @"Start";
    self.startStopButtonItem.tintColor = nil;
}

- (void)toggleStartStop {
    if (_running) {
        [self stopMonitoring];
    } else {
        [self startMonitoring];
    }
}

- (void)saveRoute {
    // Get the current timestamp for the filename
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = @"yyyyMMdd'T'HHmmss'.xml'";
    NSString *filename = [dateFormatter stringFromDate:[NSDate date]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];

    NSMutableArray *coordinates = [NSMutableArray array];
    for (CLLocation *location in _route.locations) {
        [coordinates addObject:[NSString stringWithFormat:@"%f,%f,%f",
                                location.coordinate.latitude,
                                location.coordinate.longitude,
                                location.altitude]];
    }

    NSDictionary *dictionary = @{
        @"startTimestamp" : _route.firstLocation.timestamp,
        @"stopTimestamp" : _route.lastLocation.timestamp,
        @"coordinates" : coordinates
    };
    [dictionary writeToFile:filePath atomically:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

    switch (indexPath.row) {
        case RowLatitude:
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.5f", _lastLocation.coordinate.latitude];
            break;

        case RowLongitude:
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.5f", _lastLocation.coordinate.longitude];
            break;

        case RowAltitude:
            cell.textLabel.text = @"Altitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.altitude];
            break;

        case RowCourse:
            cell.textLabel.text = @"Course";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", _lastLocation.course];
            break;

        case RowSpeed:
            cell.textLabel.text = @"Speed";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MPH", _lastLocation.speed * MPS_TO_MIPH];
            break;

        case RowDuration:
            cell.textLabel.text = @"Duration";

            NSInteger duration = (NSInteger)[_route duration];
            NSInteger hour = duration / 3600;
            NSInteger min = (duration / 60) % 60;
            NSInteger sec = duration % 60;

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
            break;

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
        [_route addLocation:location];
        _lastLocation = location;
    }

    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end

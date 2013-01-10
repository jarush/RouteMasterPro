//
//  RouteViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface RouteViewController () <CLLocationManagerDelegate> {
    UILabel *label;
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
}
@end

@implementation RouteViewController

- (void)viewDidLoad {
    self.title = @"Route";

    label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self.view addSubview:label];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (void)dealloc {
    [label release];
    [locationManager release];
    [lastLocation release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    label.frame = CGRectInset(self.view.bounds, 10, 10);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    
    double distance = [lastLocation distanceFromLocation:location];

    label.text = [NSString stringWithFormat:@"Lat: %f\nLon: %f\nAlt: %f\nCourse: %f\nSpeed: %f\nhdop: %f\nvdop: %f\nTime: %@\nDist: %f",
                  location.coordinate.latitude,
                  location.coordinate.longitude,
                  location.altitude,
                  location.course,
                  location.speed,
                  location.horizontalAccuracy,
                  location.verticalAccuracy,
                  location.timestamp,
                  distance];

    lastLocation = [location retain];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end

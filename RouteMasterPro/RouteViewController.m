//
//  RouteViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RouteOverlayView.h"

#define DELTA_DISTANCE 10.0f

@interface RouteViewController () <CLLocationManagerDelegate, MKMapViewDelegate> {
    UIBarButtonItem *_barButtonItem;

    MKMapView *_mapView;
    RouteOverlayView *_routeOverlayView;

    BOOL _running;
    Route *_route;
    CLLocationManager *_locationManager;
}
@end

@implementation RouteViewController

- (void)loadView {
    _mapView = [[MKMapView alloc] init];
    self.view = _mapView;
}

- (void)viewDidLoad {
    self.title = @"Route";

    _barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self
                                                     action:@selector(toggleStartStop)];
    self.navigationItem.rightBarButtonItem = _barButtonItem;

    _mapView.delegate = self;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;

    _running = NO;
    _route = nil;

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    _locationManager.distanceFilter = DELTA_DISTANCE;
    _locationManager.delegate = self;
}

- (void)dealloc {
    [_barButtonItem release];
    [_mapView release];
    [_route release];
    [_locationManager release];
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (_running) {
        [self stopMonitoring];
    }
}

- (void)toggleStartStop {
    if (_running) {
        [self stopMonitoring];
    } else {
        [self startMonitoring];
    }
}

- (void)startMonitoring {
    _running = YES;

    _route = [[Route alloc] init];

    [_mapView addOverlay:_route];
    _mapView.userTrackingMode = MKUserTrackingModeFollow;

    [_locationManager startUpdatingLocation];

    _barButtonItem.title = @"Stop";
    _barButtonItem.tintColor = [UIColor colorWithRed:0.7f green:0.2f blue:0.2f alpha:1.0f];
}

- (void)stopMonitoring {
    _running = NO;

    [_mapView removeOverlay:_route];
    
    [_routeOverlayView release];
    _routeOverlayView = nil;

    NSLog(@"Route: %@", _route);
    [_route release];

    [_locationManager stopUpdatingLocation];

    _barButtonItem.title = @"Start";
    _barButtonItem.tintColor = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        [_route addLocation:location];
    }

    [_routeOverlayView invalidatePath];
    [_routeOverlayView setNeedsDisplayInMapRect:MKMapRectWorld];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if (_routeOverlayView == nil) {
        _routeOverlayView = [[RouteOverlayView alloc] initWithOverlay:overlay];
        _routeOverlayView.strokeColor = [UIColor redColor];
    }
    
    return _routeOverlayView;
}

@end

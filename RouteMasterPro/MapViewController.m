//
//  MapViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <CLLocationManagerDelegate> {
    MKMapView *_mapView;
}
@end

@implementation MapViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Map";
        self.tabBarItem.title = @"Map";
        self.tabBarItem.image = [UIImage imageNamed:@"map"];

        _mapView = [[MKMapView alloc] init];
        self.view = _mapView;
    }
    return self;
}

- (void)dealloc {
    [_mapView release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
}

@end

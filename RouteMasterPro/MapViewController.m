//
//  MapViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "constants.h"

@interface MapViewController () <MKMapViewDelegate> {
    UIBarButtonItem *_trackingButtonItem;
    MKMapView *_mapView;
    MKPointAnnotation *_pointAnnotation;
}
@end

@implementation MapViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Map";
        self.tabBarItem.title = @"Map";
        self.tabBarItem.image = [UIImage imageNamed:@"map"];

        _trackingButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Track"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(toggleTracking)];
        self.navigationItem.rightBarButtonItem = _trackingButtonItem;

        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        [_mapView addGestureRecognizer:[[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleLongPress:)] autorelease]];

        _pointAnnotation = nil;

        AppDelegate *appDelegate = [AppDelegate appDelegate];
        if (appDelegate.stopRegion != nil) {
            _pointAnnotation = [[MKPointAnnotation alloc] init];
            _pointAnnotation.coordinate = appDelegate.stopRegion.center;
            [_mapView addAnnotation:_pointAnnotation];
        }

        self.view = _mapView;
    }
    return self;
}

- (void)dealloc {
    [_trackingButtonItem release];
    [_mapView release];
    [_pointAnnotation release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    _mapView.showsUserLocation = NO;
    [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
}

- (void)toggleTracking {
    if (_mapView.userTrackingMode == MKUserTrackingModeNone) {
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    } else {
        [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:_mapView];
        CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];

        if (_pointAnnotation == nil) {
            _pointAnnotation = [[MKPointAnnotation alloc] init];
            [_mapView addAnnotation:_pointAnnotation];
        }

        _pointAnnotation.coordinate = coordinate;

        // Update the stop region
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        appDelegate.stopRegion = [[[CLRegion alloc] initCircularRegionWithCenter:coordinate
                                                                          radius:RADIUS_STOP_MONITORING
                                                                      identifier:@"StopRegion"] autorelease];
    }
}

#pragma mark -- Map view delegate

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    _trackingButtonItem.style = mode == MKUserTrackingModeNone ? UIBarButtonItemStylePlain : UIBarButtonItemStyleDone;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *ReuseIdentifier = @"Pin";

    if ([annotation class] == MKUserLocation.class) {
        return nil;
    }

    MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                           reuseIdentifier:ReuseIdentifier] autorelease];
    annotationView.draggable = YES;

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D coordinate = ((MKPointAnnotation*)view.annotation).coordinate;

        // Update the stop region
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        appDelegate.stopRegion = [[[CLRegion alloc] initCircularRegionWithCenter:coordinate
                                                                          radius:RADIUS_STOP_MONITORING
                                                                      identifier:@"StopRegion"] autorelease];
    }
}

@end

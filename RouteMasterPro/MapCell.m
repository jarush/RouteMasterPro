//
//  MapCell.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/19/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "MapCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MapCell

@synthesize mapView = _mapView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = NO;
        _mapView.userInteractionEnabled = NO;
        _mapView.layer.cornerRadius = 10.0;
        _mapView.delegate = self;
        [self.contentView addSubview:_mapView];
    }
    return self;
}

- (void)dealloc {
    [_mapView release];
    [super dealloc];
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    frame.size.width -= 20;
    frame.origin.x += 10;

    _mapView.frame = frame;
}

#pragma mark -- MapView delegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *polylineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
    polylineView.strokeColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f];
    return polylineView;
}

@end

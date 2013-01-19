//
//  MapCell.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/19/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapCell : UITableViewCell <MKMapViewDelegate>

@property (nonatomic, readonly) MKMapView *mapView;

@end

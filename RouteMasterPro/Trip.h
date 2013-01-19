//
//  Trip.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Trip : NSObject

@property (nonatomic, readonly) NSArray *locations;

- (void)addLocation:(CLLocation *)location;
- (CLLocation *)firstLocation;
- (CLLocation *)lastLocation;

- (CLLocationDistance)distance;
- (NSTimeInterval)duration;

- (CLLocationDistance)distanceToTrip:(Trip *)trip;
- (CLLocationDistance)distanceToLocation:(CLLocation *)location;

- (MKPolyline *)mapAnnotation;

- (void)writeToPath:(NSString *)path;
- (void)writeKmlToPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

- (void)reducePoints;

@end

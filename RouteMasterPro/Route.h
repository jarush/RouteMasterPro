//
//  Route.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Route : NSObject <NSCoding>

@property (nonatomic, readonly) NSArray *locations;

- (void)addLocation:(CLLocation *)location;
- (CLLocation *)firstLocation;
- (CLLocation *)lastLocation;

- (CLLocationDistance)distance;
- (NSTimeInterval)duration;

@end

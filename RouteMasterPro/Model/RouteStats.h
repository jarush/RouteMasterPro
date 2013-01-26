//
//  RouteStats.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/20/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"

@interface RouteStats : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger numberSamples;
@property (nonatomic, assign) double meanDuration;
@property (nonatomic, assign) double minDuration;
@property (nonatomic, assign) double maxDuration;
@property (nonatomic, assign) double meanDistance;
@property (nonatomic, assign) double minDistance;
@property (nonatomic, assign) double maxDistance;

- (void)updateStats:(Trip *)trip;

@end

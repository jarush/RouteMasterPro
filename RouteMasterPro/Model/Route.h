//
//  Route.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteStats.h"
#import "Trip.h"

@class Folder;

@interface Route : NSObject <NSCoding>

@property (nonatomic, retain) Folder *folder;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *templateFile;
@property (nonatomic, readonly) NSArray *tripFiles;
@property (nonatomic, readonly) RouteStats *routeStats;
@property (nonatomic, readonly) NSArray *hourlyRouteStats;

- (void)addTripFile:(NSString *)tripFile;
- (void)removeTripFile:(NSString *)tripFile;
- (void)updateStats:(Trip *)trip;

- (CLLocationDistance)distanceToTrip:(Trip *)inTrip;

- (void)save;
- (void)delete;

@end

//
//  Route.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"

@interface Route : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *templateFile;
@property (nonatomic, readonly) NSArray *tripFiles;

- (void)addTripFile:(NSString *)tripFile;
- (void)removeTripFile:(NSString *)tripFile;

- (CLLocationDistance)distanceToTrip:(Trip *)inTrip;

- (void)save;

@end

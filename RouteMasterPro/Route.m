//
//  Route.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Route.h"

@interface Route () {
    NSMutableArray *_locations;
}

@end

@implementation Route

@synthesize locations = _locations;

- (id)init {
    self = [super init];
    if (self) {
        _locations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addLocation:(CLLocation *)location {
    [_locations addObject:location];
}

- (CLLocation *)firstLocation {
    if ([_locations count] == 0) {
        return nil;
    }
    return [_locations objectAtIndex:0];
}

- (CLLocation *)lastLocation {
    if ([_locations count] == 0) {
        return nil;
    }
    return [_locations lastObject];
}

- (CLLocationDistance)distance {
    CLLocationDistance distance = 0.0;
    CLLocation *lastLocation = nil;

    for (CLLocation *location in _locations) {
        distance += [location distanceFromLocation:lastLocation];
        lastLocation = location;
    }

    return distance;
}

- (NSTimeInterval)duration {
    CLLocation *firstLocation = [self firstLocation];
    CLLocation *lastLocation = [self lastLocation];
    return [lastLocation.timestamp timeIntervalSinceDate:firstLocation.timestamp];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Route [distance=%f, duration=%f, points=%d]",
            [self distance], [self duration], [_locations count]];
}

#pragma mark -- NSCoding

#define kLocations @"Locations"

- (id)initWithCoder:(NSCoder *)coder {
    _locations = [[coder decodeObjectForKey:kLocations] retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_locations forKey:kLocations];
}

@end

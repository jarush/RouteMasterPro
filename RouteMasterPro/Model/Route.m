//
//  Route.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Route.h"
#import "AppDelegate.h"

@interface Route () {
    NSMutableArray *_tripFiles;
}
@end

@implementation Route

@synthesize tripFiles = _tripFiles;

- (id)init {
    self = [super init];
    if (self) {
        _tripFiles = [[NSMutableArray alloc] init];
        _routeStats = [[RouteStats alloc] init];

        NSMutableArray *array = [NSMutableArray arrayWithCapacity:24];
        for (int i = 0; i < 24; i++) {
            [array addObject:[[[RouteStats alloc] init] autorelease]];
        }
        _hourlyRouteStats = [array retain];
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_templateFile release];
    [_tripFiles release];
    [super dealloc];
}

- (void)addTripFile:(NSString *)tripFile {
    [_tripFiles addObject:tripFile];
}

- (void)removeTripFile:(NSString *)tripFile {
    [_tripFiles removeObject:tripFile];
}

- (void)updateStats:(Trip *)trip {
    // Update the overall stats
    [_routeStats updateStats:trip];

    // Update the hourly stats
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit fromDate:[trip firstLocation].timestamp];
    NSInteger hour = [dateComponents hour];
    RouteStats *routeStats = [_hourlyRouteStats objectAtIndex:hour];
    [routeStats updateStats:trip];
}

#pragma mark -- Route Matching

- (CLLocationDistance)distanceToTrip:(Trip *)inTrip {
    CLLocationDistance distance = INFINITY;

    // Get the path to the template
    NSString *tripPath = [[AppDelegate documentsPath] stringByAppendingPathComponent:_templateFile];

    // Load the trip
    Trip *trip = [[[Trip alloc] initWithPath:tripPath] autorelease];
    if (trip != nil) {
        distance = [inTrip distanceToTrip:trip];
    }

    return distance;
}

#pragma mark -- Saving/Renaming

- (void)save {
    // Create a path for the route file in the Documents folder
    NSString *routeFile = [_name stringByAppendingPathExtension:@"route"];
    NSString *routePath = [[AppDelegate documentsPath] stringByAppendingPathComponent:routeFile];

    // Save the route to the file
    [NSKeyedArchiver archiveRootObject:self toFile:routePath];
}

- (void)delete {
    // Create a path for the route file in the Documents folder
    NSString *routeFile = [_name stringByAppendingPathExtension:@"route"];
    NSString *routePath = [[AppDelegate documentsPath] stringByAppendingPathComponent:routeFile];

    [[NSFileManager defaultManager] removeItemAtPath:routePath error:nil];
}

#pragma mark -- NSCoding

#define kName @"Name"
#define kTemplateFile @"TemplateFile"
#define kTripFiles @"TripFiles"
#define kRouteStats @"RouteStats"
#define kHourlyRouteStats @"HourlyRouteStats"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [[coder decodeObjectForKey:kName] copy];
        _templateFile = [[coder decodeObjectForKey:kTemplateFile] copy];
        _tripFiles = [[coder decodeObjectForKey:kTripFiles] retain];
        _routeStats = [[coder decodeObjectForKey:kRouteStats] retain];
        _hourlyRouteStats = [[coder decodeObjectForKey:kHourlyRouteStats] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:kName];
    [coder encodeObject:_templateFile forKey:kTemplateFile];
    [coder encodeObject:_tripFiles forKey:kTripFiles];
    [coder encodeObject:_routeStats forKey:kRouteStats];
    [coder encodeObject:_hourlyRouteStats forKey:kHourlyRouteStats];
}

@end

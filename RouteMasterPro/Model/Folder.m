//
//  Folder.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/26/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Folder.h"
#import "AppDelegate.h"
#import "constants.h"

@interface Folder () {
    NSMutableArray *_routeFiles;
}
@end

@implementation Folder

@synthesize routeFiles = _routeFiles;

- (id)init {
    self = [super init];
    if (self) {
        _routeFiles = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_routeFiles release];
    [super dealloc];
}

- (void)addRouteFile:(NSString *)routeFile {
    [_routeFiles addObject:routeFile];
}

- (void)removeRouteFile:(NSString *)routeFile {
    [_routeFiles removeObject:routeFile];
}

#pragma mark - Saving/Renaming

- (void)save {
    // Create a path for the route file in the Documents folder
    NSString *folderFile = [_name stringByAppendingPathExtension:@"folder"];
    NSString *folderPath = [[AppDelegate documentsPath] stringByAppendingPathComponent:folderFile];

    // Save the route to the file
    [NSKeyedArchiver archiveRootObject:self toFile:folderPath];
}

- (void)delete {
    // Create a path for the route file in the Documents folder
    NSString *folderFile = [_name stringByAppendingPathExtension:@"folder"];
    NSString *folderPath = [[AppDelegate documentsPath] stringByAppendingPathComponent:folderFile];

    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
}

- (void)rename:(NSString *)newName {
    [self delete];
    self.name = newName;
    [self save];
}

- (void)renameRoute:(Route *)route newName:(NSString *)newName {
    // Remove the existing route file from the list of files
    NSString *oldRouteFile = [route.name stringByAppendingPathExtension:@"route"];
    [self removeRouteFile:oldRouteFile];

    // Rename the route file
    [route delete];
    route.name = newName;
    [route save];

    // Add the new route file to the list of files
    NSString *newRouteFile = [route.name stringByAppendingPathExtension:@"route"];
    [self addRouteFile:newRouteFile];

    // Save the folder
    [self save];
}

#pragma mark - Trip matching methods

- (BOOL)isSameEndPoints:(Trip *)trip {
    CLLocation *tripStartLocation = [trip firstLocation];
    CLLocation *tripStopLocation = [trip lastLocation];

    // Check if they have the same start and stop points
    if (([_startLocation distanceFromLocation:tripStartLocation] < RADIUS_STOP_MONITORING * 2) &&
        ([_stopLocation distanceFromLocation:tripStopLocation] < RADIUS_STOP_MONITORING * 2)) {
        return YES;
    }

    // Check if they have swapped start and stop points
    if (([_startLocation distanceFromLocation:tripStopLocation] < RADIUS_STOP_MONITORING * 2) &&
        ([_stopLocation distanceFromLocation:tripStartLocation] < RADIUS_STOP_MONITORING * 2)) {
        return YES;
    }

    return NO;
}

- (Route *)findMatchingRoute:(Trip *)trip {
    CLLocationDistance minDistance = INFINITY;
    Route *minRoute = nil;

    // Loop through the route files
    for (NSString *routeFile in _routeFiles) {
        NSString *routePath = [[AppDelegate documentsPath] stringByAppendingPathComponent:routeFile];

        // Load the route
        Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:routePath];
        if (route != nil) {
            // Get the distance of the trip to the route
            CLLocationDistance distance = [route distanceToTrip:trip];
            if (distance < minDistance && distance < MAX_TRIP_MATCH_DISTANCE) {
                minDistance = distance;
                minRoute = route;;
            }
        }
    }

    return minRoute;
}

#pragma mark - NSCoding

#define kName @"Name"
#define kStartLocation @"StartLocation"
#define kStopLocation @"StopLocation"
#define kRouteFiles @"RouteFiles"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [[coder decodeObjectForKey:kName] copy];
        _startLocation = [[coder decodeObjectForKey:kStartLocation] retain];
        _stopLocation = [[coder decodeObjectForKey:kStopLocation] retain];
        _routeFiles = [[coder decodeObjectForKey:kRouteFiles] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:kName];
    [coder encodeObject:_startLocation forKey:kStartLocation];
    [coder encodeObject:_stopLocation forKey:kStopLocation];
    [coder encodeObject:_routeFiles forKey:kRouteFiles];
}


@end

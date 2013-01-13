//
//  RouteManager.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/13/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteManager.h"
#import "AppDelegate.h"
#import "constants.h"

@implementation RouteManager

- (Route *)match:(Route *)inRoute {
    CLLocationDistance minDistance = INFINITY;
    Route *minRoute = nil;

    // Get the path to the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];

    // Loop through the route files
    for (NSString *file in [AppDelegate routeFilenames]) {
        NSString *path = [documentsPath stringByAppendingPathComponent:file];

        // Load the route
        Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (route != nil) {
            // Compare the routes
            CLLocationDistance distance = [inRoute distanceToRoute:route];
            if (distance < minDistance) {
                minDistance = distance;
                minRoute = route;
            }
        }
    }

    // Make sure the minimum distance route is within matching range
    if (minDistance > MAX_ROUTE_MATCH_DISTANCE) {
        return nil;
    }

    return minRoute;
}

@end

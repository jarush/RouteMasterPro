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

- (Trip *)match:(Trip *)inTrip {
    CLLocationDistance minDistance = INFINITY;
    Trip *minTrip = nil;

    // Get the path to the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];

    // Loop through the trip files
    for (NSString *file in [AppDelegate routeFilenames]) {
        NSString *path = [documentsPath stringByAppendingPathComponent:file];

        // Load the trip
        Trip *trip = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (trip != nil) {
            // Compare the trip
            CLLocationDistance distance = [inTrip distanceToTrip:trip];
            if (distance < minDistance) {
                minDistance = distance;
                minTrip = trip;
            }
        }
    }

    // Make sure the trip with the minimum distance is within matching range
    if (minDistance > MAX_TRIP_MATCH_DISTANCE) {
        return nil;
    }

    return minTrip;
}

@end

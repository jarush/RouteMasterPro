//
//  AppDelegate.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "CurrentTripViewController.h"
#import "MapViewController.h"
#import "RoutesViewController.h"
#import "StatsViewController.h"
#import "constants.h"

@implementation AppDelegate

@synthesize stopRegion = _stopRegion;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CurrentTripViewController *currentTripViewController = [[[CurrentTripViewController alloc] init] autorelease];
    MapViewController *mapViewController = [[[MapViewController alloc] init] autorelease];
    RoutesViewController *routesViewController = [[[RoutesViewController alloc] init] autorelease];
    StatsViewController *statsViewController = [[[StatsViewController alloc] init] autorelease];

    UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
    tabBarController.viewControllers = @[
        [[[UINavigationController alloc] initWithRootViewController:currentTripViewController] autorelease],
        [[[UINavigationController alloc] initWithRootViewController:mapViewController] autorelease],
        [[[UINavigationController alloc] initWithRootViewController:routesViewController] autorelease],
        [[[UINavigationController alloc] initWithRootViewController:statsViewController] autorelease]
    ];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (CLRegion *)stopRegion {
    if (_stopRegion != nil) {
        return _stopRegion;
    }

    // Load the region from file
    NSString *path = [[AppDelegate documentsPath] stringByAppendingPathComponent:@"stop.region"];
    _stopRegion = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];

    return _stopRegion;
}

- (void)setStopRegion:(CLRegion *)stopRegion {
    [_stopRegion release];
    _stopRegion = [stopRegion retain];

    // Save the region to file
    NSString *path = [[AppDelegate documentsPath] stringByAppendingPathComponent:@"stop.region"];
    [NSKeyedArchiver archiveRootObject:_stopRegion toFile:path];
}

+ (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

+ (NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSArray *)routePaths {
    // Get the list of files in the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];

    // Filter the list of filename for names ending in .route
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith[c] '.route'"];
    filenames = [filenames filteredArrayUsingPredicate:predicate];

    // Append the filtered filenames to the Documents folder to create absolute paths
    NSMutableArray *paths = [NSMutableArray array];
    for (NSString *filename in filenames) {
        [paths addObject:[documentsPath stringByAppendingPathComponent:filename]];
    }

    return paths;
}

+ (Route *)findMatchingRoute:(Trip *)trip {
    CLLocationDistance minDistance = INFINITY;
    Route *minRoute = nil;

    // Loop through the route files
    for (NSString *path in [AppDelegate routePaths]) {
        // Load the route
        Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (route != nil) {
            // Get the distance of the trip to the route
            CLLocationDistance distance = [route distanceToTrip:trip];
            if (distance < minDistance) {
                minDistance = distance;
                minRoute = route;;
            }
        }
    }

    // Make sure the trip with the minimum distance is within matching range
    if (minDistance > MAX_TRIP_MATCH_DISTANCE) {
        return nil;
    }

    return minRoute;
}

@end

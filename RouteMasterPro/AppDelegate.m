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

+ (NSArray *)tripPaths {
    // Get the list of files in the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];

    // Filter the list of filename for names ending in .route
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith[c] '.trip'"];
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
    for (NSString *routePath in [AppDelegate routePaths]) {
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

+ (void)processTrip:(Trip *)trip {
    // Get the current timestamp for the filename
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = @"yyyyMMdd'T'HHmmss";
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];

    // Create a path for the trip file in the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];
    NSString *tripFile = [timestamp stringByAppendingPathExtension:@"trip"];
    NSString *tripPath = [documentsPath stringByAppendingPathComponent:tripFile];

    // Make sure the filename is unique
    int index = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:tripPath]) {
        NSString *file = [[timestamp stringByAppendingFormat:@"-%d", index] stringByAppendingPathExtension:@"trip"];
        tripPath = [documentsPath stringByAppendingPathComponent:file];
    }

    // Reduce the points in the trip
    [trip reducePoints];

    // Save the trip to the file
    [trip writeToPath:tripPath];

    // Try and match the trip to the route
    [AppDelegate matchTrip:trip tripPath:tripPath];
}

+ (void)matchTrip:(Trip *)trip tripPath:(NSString *)tripPath {
    // Find a matching route for the trip
    Route *route = [AppDelegate findMatchingRoute:trip];
    if (route == nil) {
        NSString *name = [[tripPath lastPathComponent] stringByDeletingPathExtension];

        // Create a new route
        route = [[[Route alloc] init] autorelease];
        route.name = name;
        route.templateFile = [tripPath lastPathComponent];
    }

    // Add the trip to the route
    [route addTripFile:[tripPath lastPathComponent]];

    // Add this trip's stats to the route
    [route updateTripStats:trip];

    // Save the route
    [route save];
}

@end

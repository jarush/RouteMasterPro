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

+ (NSArray *)routeFilenames {
    NSString *documentsPath = [AppDelegate documentsPath];
    NSArray *contentsOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith[c] '.xml'"];
    return [contentsOfDirectory filteredArrayUsingPredicate:predicate];
}

@end

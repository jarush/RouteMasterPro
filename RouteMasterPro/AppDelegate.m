//
//  AppDelegate.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "CurrentRouteViewController.h"
#import "MapViewController.h"
#import "RoutesViewController.h"
#import "StatsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CurrentRouteViewController *currentRouteViewController = [[[CurrentRouteViewController alloc] init] autorelease];
    MapViewController *mapViewController = [[[MapViewController alloc] init] autorelease];
    RoutesViewController *routesViewController = [[[RoutesViewController alloc] init] autorelease];
    StatsViewController *statsViewController = [[[StatsViewController alloc] init] autorelease];

    UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
    tabBarController.viewControllers = @[
        [[UINavigationController alloc] initWithRootViewController:currentRouteViewController],
        [[UINavigationController alloc] initWithRootViewController:mapViewController],
        [[UINavigationController alloc] initWithRootViewController:routesViewController],
        [[UINavigationController alloc] initWithRootViewController:statsViewController]
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

+ (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

+ (NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

@end

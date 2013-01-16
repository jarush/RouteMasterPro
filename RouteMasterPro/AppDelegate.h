//
//  AppDelegate.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "Trip.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CLRegion *stopRegion;

+ (AppDelegate *)appDelegate;

+ (NSString *)documentsPath;
+ (NSArray *)routePaths;
+ (NSArray *)tripPaths;

+ (Route *)findMatchingRoute:(Trip *)trip;
+ (void)processTrip:(Trip *)trip;
+ (void)matchTrip:(Trip *)trip tripPath:(NSString *)tripPath;

@end

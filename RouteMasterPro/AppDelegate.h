//
//  AppDelegate.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CLRegion *stopRegion;

+ (AppDelegate *)appDelegate;
+ (NSString *)documentsPath;
+ (NSArray *)routeFilenames;

@end

//
//  Folder.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/26/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "Trip.h"

@interface Folder : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) CLLocation *startLocation;
@property (nonatomic, retain) CLLocation *stopLocation;
@property (nonatomic, readonly) NSArray *routeFiles;

- (void)addRouteFile:(NSString *)routeFile;
- (void)removeRouteFile:(NSString *)routeFile;

- (void)save;
- (void)delete;

- (void)rename:(NSString *)newName;
- (void)renameRoute:(Route *)route newName:(NSString *)newName;

- (BOOL)isSameEndPoints:(Trip *)trip;
- (Route *)findMatchingRoute:(Trip *)trip;

@end

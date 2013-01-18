//
//  Ecef.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/17/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Ecef : NSObject

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;

- (id)initFromX:(double)x y:(double)y z:(double)z;
- (id)initFromCoord:(CLLocationCoordinate2D)coord height:(double)height;

+ (Ecef *)ecefFromX:(double)x y:(double)y z:(double)z;
+ (Ecef *)ecefFromCoord:(CLLocationCoordinate2D)coord height:(double)height;

- (Ecef *)add:(Ecef *)v;
- (Ecef *)sub:(Ecef *)v;
- (double)dot:(Ecef *)v;
- (Ecef *)mult:(double)s;
- (double)norm2;
- (double)dist2:(Ecef *)ecef;
- (double)distanceToSegmentSquaredFrom:(Ecef *)ecef1 to:(Ecef *)ecef2;

@end

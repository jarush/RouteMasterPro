//
//  Vec3D.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/17/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Vec3D : NSObject

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;

- (id)initWithX:(double)x y:(double)y z:(double)z;

+ (Vec3D *)vec3DWithX:(double)x y:(double)y z:(double)z;
+ (Vec3D *)vec3DEcefFromCoord:(CLLocationCoordinate2D)coord height:(double)height;

- (Vec3D *)add:(Vec3D *)v;
- (Vec3D *)sub:(Vec3D *)v;
- (double)dot:(Vec3D *)v;
- (Vec3D *)mult:(double)s;

- (double)normSq;
- (double)norm;

- (double)distSq:(Vec3D *)p;
- (double)dist:(Vec3D *)p;

- (double)angle:(Vec3D *)v;

- (double)distanceSqToSegmentFrom:(Vec3D *)p1 to:(Vec3D *)p2;
- (double)perpDistanceToSegmentFrom:(Vec3D *)p1 to:(Vec3D *)p2;

@end

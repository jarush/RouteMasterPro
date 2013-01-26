//
//  Vec3D
//  RouteMasterPro
//
//  Created by Jason Rush on 1/17/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Vec3D.h"
#import <math.h>

// WGS84 Ellipsoid Parameters
#define A   (6378137.0)
#define B   (6356752.3142)
#define F   (1/298.257223563)
#define E2  ((A * A - B * B) / (A * A))
#define EP2 ((A * A - B * B) / (B * B))

// Deg/Rad Conversion
#define DEG2RAD (M_PI / 180.0);

@implementation Vec3D

- (id)initWithX:(double)x y:(double)y z:(double)z {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}

+ (Vec3D *)vec3DWithX:(double)x y:(double)y z:(double)z {
    return [[[Vec3D alloc] initWithX:x y:y z:z] autorelease];
}

+ (Vec3D *)vec3DEcefFromCoord:(CLLocationCoordinate2D)coord height:(double)height {
    double lat = coord.latitude * DEG2RAD;
    double lon = coord.longitude * DEG2RAD;

    double slat = sin(lat);
    double clat = cos(lat);
    double slon = sin(lon);
    double clon = cos(lon);

    double n = A / sqrt(1 - E2 * slat * slat);
    double x = (n + height) * clat * clon;
    double y = (n + height) * clat * slon;
    double z = (((B * B) / (A * A)) * n + height) * slat;

    return [Vec3D vec3DWithX:x y:y z:z];
}

- (Vec3D *)add:(Vec3D *)v {
    return [Vec3D vec3DWithX:(_x + v.x) y:(_y + v.y) z:(_z + v.z)];
}

- (Vec3D *)sub:(Vec3D *)v {
    return [Vec3D vec3DWithX:(_x - v.x) y:(_y - v.y) z:(_z - v.z)];
}

- (double)dot:(Vec3D *)v {
    return (_x * v.x) + (_y * v.y) + (_z * v.z);
}

- (Vec3D *)mult:(double)s {
    return [Vec3D vec3DWithX:(_x * s) y:(_y * s) z:(_z * s)];
}

- (double)normSq {
    return _x * _x + _y * _y + _z * _z;
}

- (double)norm {
    return sqrt([self normSq]);
}

- (double)distSq:(Vec3D *)p {
    return [[self sub:p] normSq];
}

- (double)dist:(Vec3D *)p {
    return sqrt([self distSq:p]);
}

- (double)angle:(Vec3D *)v {
    return acos([self dot:v] / ([self norm] * [v norm]));
}

- (double)distanceSqToSegmentFrom:(Vec3D *)p1 to:(Vec3D *)p2 {
    Vec3D *v = [p2 sub:p1];
    Vec3D *w = [self sub:p1];

    double c1 = [w dot:v];
    if (c1 <= 0.0) {
        return [self distSq:p1];
    }

    double c2 = [v normSq];
    if (c2 <= c1) {
        return [self distSq:p2];
    }

    return [self distSq:[p1 add:[v mult:c1 / c2]]];
}

- (double)perpDistanceToSegmentFrom:(Vec3D *)p1 to:(Vec3D *)p2 {
    Vec3D *v = [p2 sub:p1];
    Vec3D *w = [self sub:p1];

    double lv = [v norm];
    double lw = [w norm];

    double angle = acos([v dot:w] / (lv * lw));

    return sin(angle) * lw;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Vec3D (x=%f, y=%f, z=%f)", self.x, self.y, self.z];
}

@end

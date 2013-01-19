//
//  Ecef.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/17/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Ecef.h"
#import <math.h>

// WGS84 Ellipsoid Parameters
#define A   (6378137.0)
#define B   (6356752.3142)
#define F   (1/298.257223563)
#define E2  ((A * A - B * B) / (A * A))
#define EP2 ((A * A - B * B) / (B * B))

// Deg/Rad Conversion
#define DEG2RAD (M_PI / 180.0);

@implementation Ecef

- (id)initFromX:(double)x y:(double)y z:(double)z {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}

- (id)initFromCoord:(CLLocationCoordinate2D)coord height:(double)height {
    self = [super init];
    if (self) {
        double lat = coord.latitude * DEG2RAD;
        double lon = coord.longitude * DEG2RAD;

        double slat = sin(lat);
        double clat = cos(lat);
        double slon = sin(lon);
        double clon = cos(lon);

        double n = A / sqrt(1 - E2 * slat * slat);
        _x = (n + height) * clat * clon;
        _y = (n + height) * clat * slon;
        _z = (((B * B) / (A * A)) * n + height) * slat;
    }
    return self;
}

+ (Ecef *)ecefFromCoord:(CLLocationCoordinate2D)coord height:(double)height {
    return [[[Ecef alloc] initFromCoord:coord height:height] autorelease];
}

+ (Ecef *)ecefFromX:(double)x y:(double)y z:(double)z {
    return [[[Ecef alloc] initFromX:x y:y z:z] autorelease];
}

- (Ecef *)add:(Ecef *)v {
    return [Ecef ecefFromX:(_x + v.x) y:(_y + v.y) z:(_z + v.z)];
}

- (Ecef *)sub:(Ecef *)v {
    return [Ecef ecefFromX:(_x - v.x) y:(_y - v.y) z:(_z - v.z)];
}

- (double)dot:(Ecef *)v {
    return (_x * v.x) + (_y * v.y) + (_z * v.z);
}

- (Ecef *)mult:(double)s {
    return [Ecef ecefFromX:(_x * s) y:(_y * s) z:(_z * s)];
}

- (double)norm2 {
    return _x * _x + _y * _y + _z * _z;
}

- (double)norm {
    return sqrt([self norm2]);
}

- (double)dist2:(Ecef *)ecef {
    return [[self sub:ecef] norm2];
}

- (double)distanceToSegmentSquaredFrom:(Ecef *)ecef1 to:(Ecef *)ecef2 {
    Ecef *v = [ecef2 sub:ecef1];
    Ecef *w = [self sub:ecef1];

    double c1 = [w dot:v];
    if (c1 <= 0.0) {
        return [self dist2:ecef1];
    }

    double c2 = [v norm2];
    if (c2 <= c1) {
        return [self dist2:ecef2];
    }

    return [self dist2:[ecef1 add:[v mult:c1 / c2]]];
}

- (double)angle:(Ecef *)ecef {
    return acos([self dot:ecef] / ([self norm] * [ecef norm]));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ECEF (x=%f, y=%f, z=%f)", self.x, self.y, self.z];
}

@end

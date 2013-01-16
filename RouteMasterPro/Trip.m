//
//  Trip.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Trip.h"
#import <MapKit/MapKit.h>
#import "constants.h"

@interface Trip () {
    NSMutableArray *_locations;
}

@end

@implementation Trip

@synthesize locations = _locations;

double distanceToSegment2(MKMapPoint a, MKMapPoint b, MKMapPoint p);

- (id)init {
    self = [super init];
    if (self) {
        _locations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addLocation:(CLLocation *)location {
    [_locations addObject:location];
}

- (CLLocation *)firstLocation {
    if ([_locations count] == 0) {
        return nil;
    }
    return [_locations objectAtIndex:0];
}

- (CLLocation *)lastLocation {
    if ([_locations count] == 0) {
        return nil;
    }
    return [_locations lastObject];
}

- (CLLocationDistance)distance {
    CLLocationDistance distance = 0.0;
    CLLocation *lastLocation = nil;

    for (CLLocation *location in _locations) {
        distance += [location distanceFromLocation:lastLocation];
        lastLocation = location;
    }

    return distance;
}

- (NSTimeInterval)duration {
    CLLocation *firstLocation = [self firstLocation];
    CLLocation *lastLocation = [self lastLocation];
    return [lastLocation.timestamp timeIntervalSinceDate:firstLocation.timestamp];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Trip [distance=%f, duration=%f, points=%d]",
            [self distance], [self duration], [_locations count]];
}

#pragma mark -- Trip matching methods

- (CLLocationDistance)distanceToTrip:(Trip *)trip {
    CLLocationDistance maxDistance = -INFINITY;

    for (CLLocation *currentLocation in _locations) {
        if (currentLocation.horizontalAccuracy > 10) {
            NSLog(@"acc: %f", currentLocation.horizontalAccuracy);
        }
        // Compute the distance from the current location and the supplied location
        double distance = [trip distanceToLocation:currentLocation];

        // Check if the current location is within maching range
        if (distance > MAX_TRIP_MATCH_DISTANCE) {
            // Ignore the point if it's within 2x RADIUS_STOP_MONITORING of the first/last point
            double startDistance = [currentLocation distanceFromLocation:[trip firstLocation]];
            if (startDistance > RADIUS_STOP_MONITORING * 2) {
                double stopDistance = [currentLocation distanceFromLocation:[trip lastLocation]];
                if (stopDistance > RADIUS_STOP_MONITORING * 2) {
                    NSLog(@"Bad Point: [%f] %f", distance, stopDistance < startDistance ? stopDistance : startDistance);
                    // These trips can't possibly match
                    return INFINITY;
                }
            }
        } else {
            // Check if this location is larger than any others
            if (distance > maxDistance) {
                maxDistance = distance;
            }
        }
    }

    return maxDistance;
}

- (CLLocationDistance)distanceToLocation:(CLLocation *)location {
    CLLocationDistance minDistance2 = INFINITY;
    MKMapPoint lastMapPoint;
    bool hasLastMapPoint = NO;

    MKMapPoint mapPoint = MKMapPointForCoordinate(location.coordinate);

    for (CLLocation *currentLocation in _locations) {
        MKMapPoint currentMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);

        if (hasLastMapPoint) {
            // Compute the distance from the current location and the line segment from last to current
            double distance2 = distanceToSegment2(lastMapPoint, currentMapPoint, mapPoint);
            if (distance2 < minDistance2) {
                minDistance2 = distance2;
            }
        } else {
            hasLastMapPoint = YES;
        }

        lastMapPoint = currentMapPoint;
    }

    return sqrt(minDistance2);
}

double dist2(MKMapPoint a, MKMapPoint b) {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return dx * dx + dy * dy;
}

double dist(MKMapPoint a, MKMapPoint b) {
    return sqrt(dist2(a, b));
}

double distanceToSegment2(MKMapPoint a, MKMapPoint b, MKMapPoint p) {
    double d2 = dist2(a, b);
    if (d2 == 0.0) {
        return dist2(a, p);
    }

    double t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / d2;
    if (t < 0.0) {
        return dist2(p, a);
    } else if (t > 1.0) {
        return dist2(p, b);
    }

    return dist2(p, MKMapPointMake(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y)));
}

#pragma mark -- Saving

- (void)saveToCsvPath:(NSString *)path {
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }

    NSString *string = @"Latitude,Longitude,Altitude,HorizontalAccuracy,VerticalAccuracy,Course,Speed,Timestamp\n";
    [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];

    for (CLLocation *currentLocation in _locations) {
        string = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%@\n", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, currentLocation.altitude, currentLocation.horizontalAccuracy, currentLocation.verticalAccuracy, currentLocation.course, currentLocation.speed, currentLocation.timestamp];
        [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [fh closeFile];
}

#pragma mark -- NSCoding

#define kLocations @"Locations"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _locations = [[coder decodeObjectForKey:kLocations] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_locations forKey:kLocations];
}

@end

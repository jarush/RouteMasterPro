//
//  Trip.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Trip.h"
#import <MapKit/MapKit.h>
#import "BufferedReader.h"
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
        // Compute the distance from the current location and the supplied location
        double distance = [trip distanceToLocation:currentLocation];

        // Check if the current location is within maching range
        if (distance > MAX_TRIP_MATCH_DISTANCE) {
            // Ignore the point if it's within 2x RADIUS_STOP_MONITORING of the first/last point
            double startDistance = [currentLocation distanceFromLocation:[trip firstLocation]];
            if (startDistance > RADIUS_STOP_MONITORING * 2) {
                double stopDistance = [currentLocation distanceFromLocation:[trip lastLocation]];
                if (stopDistance > RADIUS_STOP_MONITORING * 2) {
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

#pragma mark -- Reading/Writing

- (void)writeToPath:(NSString *)path {
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }

    NSString *string = @"Latitude,Longitude,Altitude,HorizontalAccuracy,VerticalAccuracy,Course,Speed,Timestamp\n";
    [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];


    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];

    for (CLLocation *currentLocation in _locations) {
        string = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%@\n",
                  currentLocation.coordinate.latitude,
                  currentLocation.coordinate.longitude,
                  currentLocation.altitude,
                  currentLocation.horizontalAccuracy,
                  currentLocation.verticalAccuracy,
                  currentLocation.course,
                  currentLocation.speed,
                  [dateFormatter stringFromDate:currentLocation.timestamp]];
        [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [fh closeFile];
}

- (id)initWithPath:(NSString *)path {
    self = [self init];
    if (self) {
        NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
        [inputStream open];
        BufferedReader *reader = [[BufferedReader alloc] initWithInputStream:inputStream];

        // Skip the first line since it's the header
        [reader readLine];

        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];

        NSString *line = nil;
        while ((line = [reader readLine]) != nil) {
            NSArray *tokens = [line componentsSeparatedByString:@","];
            double latitude = [[tokens objectAtIndex:0] doubleValue];
            double longitude = [[tokens objectAtIndex:1] doubleValue];
            double altitude = [[tokens objectAtIndex:2] doubleValue];
            double horizontalAccuracy = [[tokens objectAtIndex:3] doubleValue];
            double verticalAccuracy = [[tokens objectAtIndex:4] doubleValue];
            double course = [[tokens objectAtIndex:5] doubleValue];
            double speed = [[tokens objectAtIndex:6] doubleValue];
            NSDate *timestamp = [dateFormatter dateFromString:[tokens objectAtIndex:7]];

            CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                                                 altitude:altitude
                                                       horizontalAccuracy:horizontalAccuracy
                                                         verticalAccuracy:verticalAccuracy
                                                                   course:course
                                                                    speed:speed
                                                                timestamp:timestamp];
            [_locations addObject:location];
        }

        [inputStream close];
    }
    return self;
}

@end

//
//  Trip.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Trip.h"
#import "BufferedReader.h"
#import "Vec3D.h"
#import "NSOutputStream+Utils.h"
#import "constants.h"

@interface Trip () {
    NSMutableArray *_locations;
}

@end

@implementation Trip

@synthesize locations = _locations;

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
    Vec3D *lastPoint = nil;

    Vec3D *point = [Vec3D vec3DEcefFromCoord:location.coordinate height:location.altitude];

    for (CLLocation *location in _locations) {
        Vec3D *currentPoint = [Vec3D vec3DEcefFromCoord:location.coordinate height:location.altitude];

        if (lastPoint != nil) {
            // Compute the distance from the current location and the line segment from last to current
            double distance2 = [point distanceSqToSegmentFrom:lastPoint to:currentPoint];
            if (distance2 < minDistance2) {
                minDistance2 = distance2;
            }
        }

        lastPoint = currentPoint;
    }

    return sqrt(minDistance2);
}

#pragma mark -- Mapping

- (MKPolyline *)mapAnnotation {
    NSUInteger n = [_locations count];
    NSUInteger i = 0;

    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D*)malloc(n * sizeof(CLLocationCoordinate2D));
    for (CLLocation *location in _locations) {
        coords[i++] = location.coordinate;
    }

    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:n];

    free(coords);

    return polyline;
}

#pragma mark -- Reading/Writing

- (void)writeToPath:(NSString *)path {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [outputStream open];

    [outputStream writeString:@"Latitude,Longitude,Altitude,HorizontalAccuracy,VerticalAccuracy,Course,Speed,Timestamp\n"];

    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];

    for (CLLocation *currentLocation in _locations) {
        [outputStream writeString:[NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%@\n",
                                   currentLocation.coordinate.latitude,
                                   currentLocation.coordinate.longitude,
                                   currentLocation.altitude,
                                   currentLocation.horizontalAccuracy,
                                   currentLocation.verticalAccuracy,
                                   currentLocation.course,
                                   currentLocation.speed,
                                   [dateFormatter stringFromDate:currentLocation.timestamp]]];
    }

    [outputStream close];
}

- (void)writeKmlToPath:(NSString *)path {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [outputStream open];

    [outputStream writeString:@"<kml xmlns=\"http://earth.google.com/kml/2.0\">\n"];
    [outputStream writeString:@" <Document>\n"];
    [outputStream writeString:@"  <Style id=\"linestyle\">\n"];
    [outputStream writeString:@"   <LineStyle>\n"];
    [outputStream writeString:@"    <color>7f0000ff</color>\n"];
    [outputStream writeString:@"   </LineStyle>\n"];
    [outputStream writeString:@"  </Style>\n"];
    [outputStream writeString:@"  <Placemark>\n"];
    [outputStream writeString:@"   <styleUrl>#linestyle</styleUrl>\n"];
    [outputStream writeString:@"   <LineString>\n"];
    [outputStream writeString:@"    <coordinates>\n"];

    for (CLLocation *currentLocation in _locations) {
        [outputStream writeString:[NSString stringWithFormat:@"      %f,%f,%f\n",
                                   currentLocation.coordinate.longitude,
                                   currentLocation.coordinate.latitude,
                                   currentLocation.altitude]];
    }

    [outputStream writeString:@"    </coordinates>\n"];
    [outputStream writeString:@"   </LineString>\n"];
    [outputStream writeString:@"  </Placemark>\n"];
    [outputStream writeString:@" </Document>\n"];
    [outputStream writeString:@"</kml>\n"];

    [outputStream close];
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

- (void)reducePoints {
}

- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon {
    int count = [points count];
    if (count < 3) {
        return points;
    }

    // Find the point with the maximum perpendicular distance
    float dmax = 0;
    int index = 0;
    for (int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self perpendicularDistance:point lineA:lineA lineB:lineB];
        if (d > dmax) {
            index = i;
            dmax = d;
        }
    }

    // If max distance is greater than epsilon, recursively simplify
    if (dmax > epsilon) {
        NSArray *results1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];

        NSArray *results2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];

        NSMutableArray *resultList = [NSMutableArray arrayWithArray:results1];
        [resultList removeLastObject];
        [resultList addObjectsFromArray:results2];

        return resultList;
    } else {
        return @[[points objectAtIndex:0], [points objectAtIndex:count - 1]];
    }
}

- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB {
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}

@end

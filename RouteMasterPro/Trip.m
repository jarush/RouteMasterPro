//
//  Trip.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Trip.h"
#import "BufferedReader.h"
#import "Ecef.h"
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
    Ecef *lastEcef = nil;

    Ecef *ecef = [Ecef ecefFromCoord:location.coordinate height:location.altitude];

    for (CLLocation *location in _locations) {
        Ecef *currentEcef = [Ecef ecefFromCoord:location.coordinate height:location.altitude];

        if (lastEcef != nil) {
            // Compute the distance from the current location and the line segment from last to current
            double distance2 = [ecef distanceToSegmentSquaredFrom:lastEcef to:currentEcef];
            if (distance2 < minDistance2) {
                minDistance2 = distance2;
            }
        }

        lastEcef = currentEcef;
    }

    return sqrt(minDistance2);
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

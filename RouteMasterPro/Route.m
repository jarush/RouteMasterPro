//
//  Route.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Route.h"
#import "AppDelegate.h"

@interface Route () {
    NSMutableArray *_tripFiles;
}
@end

@implementation Route

@synthesize tripFiles = _tripFiles;

- (id)init {
    self = [super init];
    if (self) {
        _tripFiles = [[NSMutableArray alloc] init];
        _numberSamples = 0;
        _meanDuration = 0.0;
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_templateFile release];
    [_tripFiles release];
    [super dealloc];
}

- (void)addTripFile:(NSString *)tripFile {
    [_tripFiles addObject:tripFile];
}

- (void)removeTripFile:(NSString *)tripFile {
    [_tripFiles removeObject:tripFile];
}

- (void)updateTripStats:(Trip *)trip {
    _numberSamples += 1;
    if (_numberSamples == 1) {
        _meanDuration = [trip duration];
        _meanDistance = [trip distance];
    } else {
        _meanDuration += ([trip duration] - _meanDuration) / _numberSamples;
        _meanDistance += ([trip distance] - _meanDistance) / _numberSamples;
    }
}

#pragma mark -- Route Matching

- (CLLocationDistance)distanceToTrip:(Trip *)inTrip {
    CLLocationDistance distance = INFINITY;

    // Get the path to the template
    NSString *tripPath = [[AppDelegate documentsPath] stringByAppendingPathComponent:_templateFile];

    // Load the trip
    Trip *trip = [[[Trip alloc] initWithPath:tripPath] autorelease];
    if (trip != nil) {
        distance = [inTrip distanceToTrip:trip];
    }

    return distance;
}

#pragma mark -- Saving

- (void)save {
    // Create a path for the route file in the Documents folder
    NSString *routeFile = [_name stringByAppendingPathExtension:@"route"];
    NSString *routePath = [[AppDelegate documentsPath] stringByAppendingPathComponent:routeFile];

    // Save the route to the file
    [NSKeyedArchiver archiveRootObject:self toFile:routePath];
}

#pragma mark -- NSCoding

#define kName @"Name"
#define kTemplateFile @"TemplateFile"
#define kTripFiles @"TripFiles"
#define kNumberSamples @"NumberSamples"
#define kMeanDuration @"MeanDuration"
#define kMeanDistance @"MeanDistance"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [[coder decodeObjectForKey:kName] copy];
        _templateFile = [[coder decodeObjectForKey:kTemplateFile] copy];
        _tripFiles = [[coder decodeObjectForKey:kTripFiles] retain];
        _numberSamples = [coder decodeIntegerForKey:kNumberSamples];
        _meanDuration = [coder decodeDoubleForKey:kMeanDuration];
        _meanDistance = [coder decodeDoubleForKey:kMeanDistance];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:kName];
    [coder encodeObject:_templateFile forKey:kTemplateFile];
    [coder encodeObject:_tripFiles forKey:kTripFiles];
    [coder encodeInteger:_numberSamples forKey:kNumberSamples];
    [coder encodeDouble:_meanDuration forKey:kMeanDuration];
    [coder encodeDouble:_meanDistance forKey:kMeanDistance];
}

@end

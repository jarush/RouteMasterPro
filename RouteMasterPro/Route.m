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
    NSMutableArray *_tripPaths;
}
@end

@implementation Route

@synthesize tripFiles = _tripFiles;

- (id)init {
    self = [super init];
    if (self) {
        _tripFiles = [[NSMutableArray alloc] init];
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

#pragma mark -- Route Matching

- (CLLocationDistance)distanceToTrip:(Trip *)inTrip {
    CLLocationDistance distance = INFINITY;

    // Get the path to the template
    NSString *path = [[AppDelegate documentsPath] stringByAppendingPathComponent:_templateFile];

    // Load the trip
    Trip *trip = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (trip != nil) {
        distance = [inTrip distanceToTrip:trip];
    }

    return distance;
}

#pragma mark -- NSCoding

#define kName @"Name"
#define kTemplateFile @"TemplateFile"
#define kTripFiles @"TripFiles"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [[coder decodeObjectForKey:kName] copy];
        _templateFile = [[coder decodeObjectForKey:kTemplateFile] copy];
        _tripFiles = [[coder decodeObjectForKey:kTripFiles] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:kName];
    [coder encodeObject:_templateFile forKey:kTemplateFile];
    [coder encodeObject:_tripPaths forKey:kTripFiles];
}

@end

//
//  Route.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "Route.h"

@interface Route () {
    NSMutableArray *_tripPaths;
}
@end

@implementation Route

@synthesize tripPaths = _tripPaths;

- (id)init {
    self = [super init];
    if (self) {
        _tripPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_templatePath release];
    [_tripPaths release];
    [super dealloc];
}

- (void)addTripPath:(Trip *)trip {
    [_tripPaths addObject:trip];
}


#pragma mark -- NSCoding

#define kName @"Name"
#define kTemplatePath @"TemplatePath"
#define kTripPaths @"TripPaths"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [[coder decodeObjectForKey:kName] copy];
        _templatePath = [[coder decodeObjectForKey:kTemplatePath] copy];
        _tripPaths = [[coder decodeObjectForKey:kTripPaths] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:kName];
    [coder encodeObject:_templatePath forKey:kTemplatePath];
    [coder encodeObject:_tripPaths forKey:kTripPaths];
}

@end

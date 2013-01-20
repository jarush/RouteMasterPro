//
//  RouteStats.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/20/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteStats.h"

@implementation RouteStats

- (id)init {
    self = [super init];
    if (self) {
        _numberSamples = 0;
        _meanDuration = 0.0;
        _meanDistance = 0.0;
    }
    return self;
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

#pragma mark -- NSCoding

#define kNumberSamples @"NumberSamples"
#define kMeanDuration @"MeanDuration"
#define kMeanDistance @"MeanDistance"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _numberSamples = [coder decodeIntegerForKey:kNumberSamples];
        _meanDuration = [coder decodeDoubleForKey:kMeanDuration];
        _meanDistance = [coder decodeDoubleForKey:kMeanDistance];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:_numberSamples forKey:kNumberSamples];
    [coder encodeDouble:_meanDuration forKey:kMeanDuration];
    [coder encodeDouble:_meanDistance forKey:kMeanDistance];
}

@end

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
        _minDuration = INFINITY;
        _maxDuration = -INFINITY;
        _meanDistance = 0.0;
        _minDistance = INFINITY;
        _maxDistance = -INFINITY;
    }
    return self;
}

- (void)updateTripStats:(Trip *)trip {
    double duration = [trip duration];
    double distance = [trip distance];
    
    _numberSamples += 1;
    if (_numberSamples == 1) {
        _meanDuration = duration;
        _meanDistance = distance;
    } else {
        _meanDuration += (duration - _meanDuration) / _numberSamples;
        _meanDistance += (distance - _meanDistance) / _numberSamples;
    }

    if (distance < _minDuration) {
        _minDuration = duration;
    }
    if (distance > _maxDuration) {
        _maxDuration = duration;
    }

    if (distance < _minDistance) {
        _minDistance = distance;
    }
    if (distance > _maxDistance) {
        _maxDistance = distance;
    }
}

#pragma mark -- NSCoding

#define kNumberSamples @"NumberSamples"
#define kMeanDuration @"MeanDuration"
#define kMinDuration @"MinDuration"
#define kMaxDuration @"MaxDuration"
#define kMeanDistance @"MeanDistance"
#define kMinDistance @"MinDistance"
#define kMaxDistance @"MaxDistance"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _numberSamples = [coder decodeIntegerForKey:kNumberSamples];
        _meanDuration = [coder decodeDoubleForKey:kMeanDuration];
        _minDuration = [coder decodeDoubleForKey:kMinDuration];
        _maxDuration = [coder decodeDoubleForKey:kMaxDuration];
        _meanDistance = [coder decodeDoubleForKey:kMeanDistance];
        _minDistance = [coder decodeDoubleForKey:kMinDistance];
        _maxDistance = [coder decodeDoubleForKey:kMaxDistance];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:_numberSamples forKey:kNumberSamples];
    [coder encodeDouble:_meanDuration forKey:kMeanDuration];
    [coder encodeDouble:_minDuration forKey:kMinDuration];
    [coder encodeDouble:_maxDuration forKey:kMaxDuration];
    [coder encodeDouble:_meanDistance forKey:kMeanDistance];
    [coder encodeDouble:_minDistance forKey:kMinDistance];
    [coder encodeDouble:_maxDistance forKey:kMaxDistance];
}

@end

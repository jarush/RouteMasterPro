//
//  Route.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"

@interface Route : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *templatePath;
@property (nonatomic, readonly) NSArray *tripPaths;

- (void)addTripPath:(Trip *)trip;

@end

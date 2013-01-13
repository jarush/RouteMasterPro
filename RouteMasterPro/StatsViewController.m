//
//  StatsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Stats";
        self.tabBarItem.title = @"Stats";
        self.tabBarItem.image = [UIImage imageNamed:@"stats"];
    }
    return self;
}

@end

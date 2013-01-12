//
//  CurrentRouteViewController.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface CurrentRouteViewController : UITableViewController

@property (nonatomic, readonly) UIBarButtonItem *startStopButtonItem;
@property (nonatomic, readonly) Route *route;

@end

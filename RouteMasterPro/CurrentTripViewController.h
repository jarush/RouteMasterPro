//
//  CurrentTripViewController.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface CurrentTripViewController : UITableViewController

@property (nonatomic, readonly) Trip *trip;

@end

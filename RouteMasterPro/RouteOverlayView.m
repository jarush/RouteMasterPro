//
//  RouteOverlayView.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/10/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteOverlayView.h"
#import "Route.h"

@implementation RouteOverlayView

- (void)createPath {
    Route *route = (Route *)self.overlay;
    if ([route.locations count] < 2) {
        return;
    }

    BOOL firstLocation = YES;
    CGMutablePathRef path = CGPathCreateMutable();
    for (CLLocation *location in route.locations) {
        // Convert the coordinate to a point on the screen
        MKMapPoint mapPoint = MKMapPointForCoordinate(location.coordinate);
        CGPoint point = [self pointForMapPoint:mapPoint];

        if (firstLocation) {
            CGPathMoveToPoint(path, NULL, point.x, point.y);
            firstLocation = NO;
        } else {
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }
    }

    self.path = path;
}

@end

//
//  StatsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "StatsViewController.h"
#import "Route.h"
#import "AppDelegate.h"

@interface StatsViewController () <UIWebViewDelegate> {
    UIWebView *_webView;
}
@end

@implementation StatsViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Stats";
        self.tabBarItem.title = @"Stats";
        self.tabBarItem.image = [UIImage imageNamed:@"stats"];

        NSString *path = [[NSBundle mainBundle] pathForResource:@"graph" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path];

        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        _webView.userInteractionEnabled = NO;
        _webView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];

        self.view = _webView;
    }
    return self;
}

- (void)dealloc {
    [_webView release];
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSMutableString *dataStr = [NSMutableString string];
    NSInteger seriesNumber = 0;

    // Loop through the route files
    for (NSString *routePath in [AppDelegate routePaths]) {
        // Load the route
        Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:routePath];
        if (route != nil) {
            // Determine the units for the chart
            double divisor;
            if (route.routeStats.maxDuration > 3600) {
                divisor = 3600.0;
            } else if (route.routeStats.maxDuration > 60) {
                divisor = 60.0;
            } else {
                divisor = 1.0;
            }

            // Add the hourly route stats
            NSMutableString *seriesStr = [NSMutableString string];
            [seriesStr appendFormat:@"var s%d = [", seriesNumber];
            for (NSInteger hour = 0; hour <= 24; hour++) {
                RouteStats *routeStats = [route.hourlyRouteStats objectAtIndex:hour % 24];
                [seriesStr appendFormat:@"[%d,%0.1f],", hour, routeStats.meanDuration / divisor];
            }
            [seriesStr appendString:@"];"];
            [_webView stringByEvaluatingJavaScriptFromString:seriesStr];

            // Add the series to the data string
            [dataStr appendFormat:@"s%d,", seriesNumber];
            seriesNumber++;
        }
    }

    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var plot1 = $.jqplot('chart1', [%@], options1);", dataStr]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var plot2 = $.jqplot('chart2', [%@], options2);", dataStr]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var plot3 = $.jqplot('chart3', [%@], options3);", dataStr]];
}

@end

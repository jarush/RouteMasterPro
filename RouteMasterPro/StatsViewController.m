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
        self.title = @"Average Duration";
        self.tabBarItem.title = @"Stats";
        self.tabBarItem.image = [UIImage imageNamed:@"stats"];


        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        _webView.userInteractionEnabled = NO;
        _webView.delegate = self;

        self.view = _webView;
    }
    return self;
}

- (void)dealloc {
    [_webView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"graph" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSMutableString *seriesNames = [NSMutableString string];
    NSMutableString *dataStr = [NSMutableString string];
    NSInteger seriesNumber;
    double divisor = 0.0;

    // Loop through the route files
    seriesNumber = 0;
    for (NSString *routePath in [AppDelegate routePaths]) {
        // Load the route
        Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:routePath];
        if (route != nil) {
            // Add the route name to the chart series
            [seriesNames appendFormat:@"{label: '%@'}, ", route.name];

            // Calculate the divisor if it hasn't been calculated
            if (divisor == 0.0) {
                if (route.routeStats.maxDuration > 3600) {
                    // Hours
                    divisor = 3600.0;
                } else if (route.routeStats.maxDuration > 60) {
                    // Minutes
                    divisor = 60.0;
                } else {
                    // Seconds
                    divisor = 1.0;
                }
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

    // Label all the series
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"options1.series = [%@];", seriesNames]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"options2.series = [%@];", seriesNames]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"options3.series = [%@];", seriesNames]];

    // Generate the plots
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var plot1 = $.jqplot('chart1', [%@], options1);", dataStr]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var plot2 = $.jqplot('chart2', [%@], options2);", dataStr]];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var plot3 = $.jqplot('chart3', [%@], options3);", dataStr]];
}

@end

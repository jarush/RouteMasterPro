//
//  StatsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "StatsViewController.h"

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
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"var line1 = [3,7,9,1,5,3,8,2,5];"];
    [str appendString:@"var line2 = [1,2,5,2,5,1,1,7,5];"];
    [str appendString:@"var options = {"];
    [str appendString:@"  legend: {show:true, location:'ne'},"];
    [str appendString:@"  axesDefaults: {labelRenderer:$.jqplot.CanvasAxisLabelRenderer}"];
    [str appendString:@"};"];
    [str appendString:@"var plot1 = $.jqplot('chart', [line1, line2], options);"];
    [_webView stringByEvaluatingJavaScriptFromString:str];
}

@end

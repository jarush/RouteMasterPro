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
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"var line1 = [[0,0],[1,0],[2,0],[3,0],[4,0],[5,1],[6,1],[7,1.5],[8,2.5],[9,2],[10,1.5],[11,0],[12,0],[13,0],[14,0],[15,1.5],[16,1.5],[17,2.5],[18,2],[19,1.5],[20,0],[21,0],[22,0],[23,0],[24,0]];"];
    [str appendString:@"var line2 = [[0,0],[1,0],[2,0],[3,0],[4,0],[5,0.9],[6,1],[7,1.3],[8,1.7],[9,2],[10,1.1],[11,0],[12,0],[13,0],[14,0],[15,1],[16,1.1],[17,2.3],[18,3],[19,2.5],[20,0],[21,0],[22,0],[23,0],[24,0]];"];
    [str appendString:@"var plot1 = $.jqplot('chart1', [line1, line2], options1);"];
    [str appendString:@"var plot2 = $.jqplot('chart2', [line1, line2], options2);"];
    [str appendString:@"var plot3 = $.jqplot('chart3', [line1, line2], options3);"];
    [_webView stringByEvaluatingJavaScriptFromString:str];
}

@end

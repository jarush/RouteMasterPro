//
//  RouteDetailsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteDetailsViewController.h"

#define METER_TO_MILES 0.000621371

enum {
    RowDistance = 0,
    RowDuration,
    RowStart,
    RowStop,
    RowPoints,
    RowCount
};

@interface RouteDetailsViewController () {
    NSDateFormatter *_dateFormatter;
}
@end

@implementation RouteDetailsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Route Details";

        _route = nil;

        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return self;
}

- (void)dealloc {
    [_route release];
    [_dateFormatter release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (indexPath.row) {
        case RowDistance:
            cell.textLabel.text = @"Distance";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f mi", [_route distance] * METER_TO_MILES];
            break;

        case RowDuration:
            cell.textLabel.text = @"Duration";

            NSInteger duration = (NSInteger)[_route duration];
            NSInteger hour = duration / 3600;
            NSInteger min = (duration / 60) % 60;
            NSInteger sec = duration % 60;

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
            break;

        case RowStart: {
            cell.textLabel.text = @"Start";
            cell.detailTextLabel.text = [_dateFormatter stringFromDate:[_route firstLocation].timestamp];
            break;
        }

        case RowStop:
            cell.textLabel.text = @"Stop";
            cell.detailTextLabel.text = [_dateFormatter stringFromDate:[_route lastLocation].timestamp];
            break;

        case RowPoints:
            cell.textLabel.text = @"Points";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [_route.locations count]];
            break;

        default:
            break;
    }

    return cell;
}

@end

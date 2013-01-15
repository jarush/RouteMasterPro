//
//  RouteDetailsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/14/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RouteDetailsViewController.h"
#import "TripDetailsViewController.h"
#import "AppDelegate.h"

enum {
    SectionDetails = 0,
    SectionTrips,
    SectionCount
};

@implementation RouteDetailsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Route Details";

        _route = nil;
    }
    return self;
}

- (void)dealloc {
    [_route release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionDetails:
            return 1;

        case SectionTrips:
            return [_route.tripFiles count];

        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (indexPath.section) {
        case SectionDetails: {
            cell.textLabel.text = @"Blah";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }

        case SectionTrips: {
            NSString *file = [_route.tripFiles objectAtIndex:indexPath.row];
            cell.textLabel.text = [file stringByDeletingPathExtension];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
        }

        default:
            break;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != SectionTrips) {
        return;
    }

    // Get the selected trip path
    NSString *file = [_route.tripFiles objectAtIndex:indexPath.row];
    NSString *path = [[AppDelegate documentsPath] stringByAppendingPathComponent:file];

    Trip *trip = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (trip != nil) {
        // Push on a trip details view
        TripDetailsViewController *tripDetailsViewController = [[[TripDetailsViewController alloc] init] autorelease];
        tripDetailsViewController.trip = trip;
        [self.navigationController pushViewController:tripDetailsViewController animated:YES];
    }
}

@end

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SectionDetails:
            return @"Details";

        case SectionTrips:
            return @"Trips";

        default:
            break;
    }
    
    return nil;
}

#define kDetailCellIdentifier @"DetailCell"
#define kTripCellIdentifier @"TripCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = indexPath.section == 0 ? kDetailCellIdentifier : kTripCellIdentifier;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }

    switch (indexPath.section) {
        case SectionDetails: {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = _route.name;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }

        case SectionTrips: {
            NSString *file = [_route.tripFiles objectAtIndex:indexPath.row];
            cell.textLabel.text = [file stringByDeletingPathExtension];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }

        default:
            break;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionTrips) {
        // Only allow deleting non-template trips
        NSString *file = [_route.tripFiles objectAtIndex:indexPath.row];
        return ![_route.templateFile isEqualToString:file];
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the selected trip path
    NSString *file = [_route.tripFiles objectAtIndex:indexPath.row];
    NSString *path = [[AppDelegate documentsPath] stringByAppendingPathComponent:file];

    // Delete the trip
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

    // Remove the trip from the route and save it
    [_route removeTripFile:file];
    [_route save];

    // Notify the table view the row was deleted
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != SectionTrips) {
        return;
    }

    // Get the selected trip path
    NSString *file = [_route.tripFiles objectAtIndex:indexPath.row];
    NSString *path = [[AppDelegate documentsPath] stringByAppendingPathComponent:file];

    // Load the trip
    Trip *trip = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (trip != nil) {
        // Push on a trip details view
        TripDetailsViewController *tripDetailsViewController = [[[TripDetailsViewController alloc] init] autorelease];
        tripDetailsViewController.trip = trip;
        [self.navigationController pushViewController:tripDetailsViewController animated:YES];
    }
}

@end

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
#import "constants.h"

enum {
    SectionDetails = 0,
    SectionTrips,
    SectionCount
};

enum {
    RowDetailsName = 0,
    RowDetailsAvgDuration,
    RowDetailsAvgDistance,
    RowDetailsAvgSpeed,
    RowDetailsNumberSamples,
    RowDetailsCount
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
            return RowDetailsCount;

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

#define kTripCellIdentifier @"TripCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case SectionDetails: {
            cell = [self tableView:tableView detailCellForRow:indexPath.row];
            break;
        }

        case SectionTrips: {
            cell = [self tableView:tableView tripCellForRow:indexPath.row];
            break;
        }

        default:
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView detailCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"DetailCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    switch (row) {
        case RowDetailsName: {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = _route.name;
            break;
        }

        case RowDetailsAvgDuration: {
            cell.textLabel.text = @"Avg Duration";

            NSInteger duration = _route.meanDuration;
            NSInteger hour = duration / 3600;
            NSInteger min = (duration / 60) % 60;
            NSInteger sec = duration % 60;

            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
            break;
        }

        case RowDetailsAvgDistance: {
            cell.textLabel.text = @"Avg Distance";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f mi", _route.meanDistance * METER_TO_MILES];
            break;
        }

        case RowDetailsAvgSpeed: {
            cell.textLabel.text = @"Avg Speed";

            double duration = _route.meanDuration;
            if (duration == 0.0) {
                cell.detailTextLabel.text = @"Unknown";
            } else {
                double avgSpeed = _route.meanDistance / duration;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f MPH", avgSpeed * MPS_TO_MIPH];
            }
            break;
        }

        case RowDetailsNumberSamples: {
            cell.textLabel.text = @"Num Samples";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _route.numberSamples];
            break;
        }

        default:
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView tripCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"TripCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }


    NSString *file = [_route.tripFiles objectAtIndex:row];
    cell.textLabel.text = [file stringByDeletingPathExtension];

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
    NSString *tripFile = [_route.tripFiles objectAtIndex:indexPath.row];
    NSString *tripPath = [[AppDelegate documentsPath] stringByAppendingPathComponent:tripFile];

    // Load the trip
    Trip *trip = [[[Trip alloc] initWithPath:tripPath] autorelease];
    if (trip != nil) {
        // Push on a trip details view
        TripDetailsViewController *tripDetailsViewController = [[[TripDetailsViewController alloc] init] autorelease];
        tripDetailsViewController.trip = trip;
        [self.navigationController pushViewController:tripDetailsViewController animated:YES];
    }
}

@end

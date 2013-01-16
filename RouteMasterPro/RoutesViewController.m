//
//  RoutesViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RoutesViewController.h"
#import "Route.h"
#import "RouteDetailsViewController.h"
#import "AppDelegate.h"

@interface RoutesViewController () {
    NSMutableArray *_paths;
}
@end

@implementation RoutesViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Routes";
        self.tabBarItem.title = @"Routes";
        self.tabBarItem.image = [UIImage imageNamed:@"list"];

        UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Recompute"
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(recomputeRoutes)] autorelease];
        self.navigationItem.rightBarButtonItem = barButtonItem;

    }
    return self;
}

- (void)dealloc {
    [_paths release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Load the list of route files
    _paths = [[AppDelegate routePaths] mutableCopy];

    [self.tableView reloadData];
}

- (void)recomputeRoutes {
    // Delete all the route files
    for (NSString *path in _paths) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    // Process the trip
    for (NSString *path in [AppDelegate tripPaths]) {
        // Load the trip
        Trip *trip = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (trip != nil) {
            [AppDelegate matchTrip:trip tripPath:path];
        }
    }

    // Load the list of route files
    _paths = [[AppDelegate routePaths] mutableCopy];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_paths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSString *path = [_paths objectAtIndex:indexPath.row];
    NSString *routeName = [[path lastPathComponent] stringByDeletingPathExtension];
    cell.textLabel.text = routeName;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    // Get the filename to delete
    NSString *routePath = [_paths objectAtIndex:indexPath.row];

    // Load the route
    Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:routePath];
    if (route != nil) {
        // Delete all the trips associated with the route
        for (NSString *tripFile in route.tripFiles) {
            NSString *tripPath = [[AppDelegate documentsPath] stringByAppendingPathComponent:tripFile];
            [[NSFileManager defaultManager] removeItemAtPath:tripPath error:nil];
        }
    }

    // Delete the route file
    [[NSFileManager defaultManager] removeItemAtPath:routePath error:nil];

    // Remove the filename from the array
    [_paths removeObjectAtIndex:indexPath.row];

    // Notify the table view the row was deleted
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [_paths objectAtIndex:indexPath.row];

    // Load the route
    Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (route != nil) {
        // Push on a route details view
        RouteDetailsViewController *routeDetailsViewController = [[[RouteDetailsViewController alloc] init] autorelease];
        routeDetailsViewController.route = route;
        [self.navigationController pushViewController:routeDetailsViewController animated:YES];
    }
}

@end

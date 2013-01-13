//
//  RoutesViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RoutesViewController.h"
#import "RouteDetailsViewController.h"
#import "AppDelegate.h"

@interface RoutesViewController () {
    NSMutableArray *_files;
}
@end

@implementation RoutesViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Routes";
        self.tabBarItem.title = @"Routes";
        self.tabBarItem.image = [UIImage imageNamed:@"list"];
    }
    return self;
}

- (void)dealloc {
    [_files release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Load the list of route files
    _files = [[AppDelegate routeFilenames] mutableCopy];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [_files objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    // Get the filename to delete
    NSString *filename = [_files objectAtIndex:indexPath.row];

    // Get the path to the file in the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];
    NSString *path = [documentsPath stringByAppendingPathComponent:filename];

    // Delete the file
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

    // Remove the filename from the array
    [_files removeObjectAtIndex:indexPath.row];

    // Notify the table view the row was deleted
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filename = [_files objectAtIndex:indexPath.row];

    // Get the path to the file in the Documents folder
    NSString *documentsPath = [AppDelegate documentsPath];
    NSString *path = [documentsPath stringByAppendingPathComponent:filename];

    Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (route != nil) {
        // Push on a details view
        RouteDetailsViewController *routeDetailsViewController = [[[RouteDetailsViewController alloc] init] autorelease];
        routeDetailsViewController.route = route;
        [self.navigationController pushViewController:routeDetailsViewController animated:YES];
    }
}

@end

//
//  FolderDetailsViewController.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/26/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "FolderDetailsViewController.h"
#import "RenameFolderViewController.h"
#import "RouteDetailsViewController.h"
#import "AppDelegate.h"
#import "Route.h"

@implementation FolderDetailsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UIBarButtonItem *renameBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Rename"
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(renamePressed)] autorelease];
        self.navigationItem.rightBarButtonItem = renameBarButtonItem;

    }
    return self;
}

- (void)dealloc {
    [_folder release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = _folder.name;

    [self.tableView reloadData];
}

- (void)renamePressed {
    RenameFolderViewController *renameFolderViewController = [[RenameFolderViewController alloc] init];
    renameFolderViewController.folder = _folder;

    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:renameFolderViewController] autorelease];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_folder.routeFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSString *file = [_folder.routeFiles objectAtIndex:indexPath.row];
    cell.textLabel.text = [file stringByDeletingPathExtension];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    // Get the filename to delete
    NSString *routeFile = [_folder.routeFiles objectAtIndex:indexPath.row];
    NSString *routePath = [[AppDelegate documentsPath] stringByAppendingPathComponent:routeFile];

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

    // Remove the filename from the folder and save the folder
    [_folder removeRouteFile:routeFile];
    [_folder save];

    // Notify the table view the row was deleted
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create a path for the route file in the Documents folder
    NSString *routeFile = [_folder.routeFiles objectAtIndex:indexPath.row];
    NSString *routePath = [[AppDelegate documentsPath] stringByAppendingPathComponent:routeFile];

    // Load the route
    Route *route = [NSKeyedUnarchiver unarchiveObjectWithFile:routePath];
    if (route != nil) {
        // Update the route with the folder it's in
        route.folder = _folder;
        
        // Push on a route details view
        RouteDetailsViewController *routeDetailsViewController = [[[RouteDetailsViewController alloc] init] autorelease];
        routeDetailsViewController.route = route;
        [self.navigationController pushViewController:routeDetailsViewController animated:YES];
    }
}

@end

//
//  FoldersViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "FoldersViewController.h"
#import <MessageUI/MessageUI.h>
#import "FolderDetailsViewController.h"
#import "AppDelegate.h"
#import "Folder.h"
#import "Route.h"
#import "Trip.h"

@interface FoldersViewController () <MFMailComposeViewControllerDelegate> {
    NSMutableArray *_paths;
}
@end

@implementation FoldersViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Folders";
        self.tabBarItem.title = @"Folders";
        self.tabBarItem.image = [UIImage imageNamed:@"list"];

        UIBarButtonItem *recomputeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Recompute"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(recomputePressed)] autorelease];
        self.navigationItem.leftBarButtonItem = recomputeButton;

        UIBarButtonItem *exportTripsButton = [[[UIBarButtonItem alloc] initWithTitle:@"CSV"
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(exportTripsPressed)] autorelease];
        UIBarButtonItem *exportKmlButton = [[[UIBarButtonItem alloc] initWithTitle:@"KML"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(exportKmlPressed)] autorelease];
        self.navigationItem.rightBarButtonItems = @[exportTripsButton, exportKmlButton];

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
    [_paths release];
    _paths = [[AppDelegate folderPaths] mutableCopy];

    [self.tableView reloadData];
}

- (void)recomputePressed {
    // Delete all the folder files
    for (NSString *path in _paths) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    // Delete all the route files
    for (NSString *path in [AppDelegate routePaths]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    // Process the trip
    for (NSString *tripPath in [AppDelegate tripPaths]) {
        // Load the trip
        Trip *trip = [[[Trip alloc] initWithPath:tripPath] autorelease];
        if (trip != nil) {
            [AppDelegate matchTrip:trip tripPath:tripPath];
        }
    }

    // Load the list of folder files
    _paths = [[AppDelegate folderPaths] mutableCopy];

    [self.tableView reloadData];
}

#pragma mark - Export via mail

- (void)exportTripsPressed {
    MFMailComposeViewController *viewController = [[[MFMailComposeViewController alloc] init] autorelease];
    viewController.mailComposeDelegate = self;
    [viewController setSubject:@"Trips"];
    [viewController setMessageBody:@"See attached trip files:" isHTML:NO];

    for (NSString *tripPath in [AppDelegate tripPaths]) {
        [viewController addAttachmentData:[NSData dataWithContentsOfFile:tripPath]
                                 mimeType:@"text/csv"
                                 fileName:[tripPath lastPathComponent]];
    }

    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)exportKmlPressed {
    MFMailComposeViewController *viewController = [[[MFMailComposeViewController alloc] init] autorelease];
    viewController.mailComposeDelegate = self;
    [viewController setSubject:@"KML Files"];
    [viewController setMessageBody:@"See attached KML files:" isHTML:NO];

    for (NSString *tripPath in [AppDelegate tripPaths]) {
        NSString *kmlPath = [[tripPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"kml"];

        Trip *trip = [[[Trip alloc] initWithPath:tripPath] autorelease];
        if (trip != nil) {
            [trip writeKmlToPath:kmlPath];
        }

        [viewController addAttachmentData:[NSData dataWithContentsOfFile:kmlPath]
                                 mimeType:@"text/xml"
                                 fileName:[kmlPath lastPathComponent]];
    }

    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    NSString *folderName = [[path lastPathComponent] stringByDeletingPathExtension];
    cell.textLabel.text = folderName;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    // Get the filename to delete
    NSString *folderPath = [_paths objectAtIndex:indexPath.row];

    // Load the folder
    Folder *folder = [NSKeyedUnarchiver unarchiveObjectWithFile:folderPath];
    if (folder != nil) {
        for (NSString *routeFile in folder.routeFiles) {
            // Get the path to the route
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

            // Delete the route
            [route delete];
        }
    }

    // Delete the folder
    [folder delete];

    // Remove the filename from the array
    [_paths removeObjectAtIndex:indexPath.row];

    // Notify the table view the row was deleted
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *folderPath = [_paths objectAtIndex:indexPath.row];

    // Load the route
    Folder *folder = [NSKeyedUnarchiver unarchiveObjectWithFile:folderPath];
    if (folder != nil) {
        // Push on a folder details view
        FolderDetailsViewController *folderDetailsViewController = [[[FolderDetailsViewController alloc] init] autorelease];
        folderDetailsViewController.folder = folder;
        [self.navigationController pushViewController:folderDetailsViewController animated:YES];
    }
}

@end

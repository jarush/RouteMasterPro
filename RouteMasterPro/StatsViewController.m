//
//  StatsViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/26/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "StatsViewController.h"
#import "StatsAvgDurationViewController.h"
#import "AppDelegate.h"
#import "Folder.h"

@interface StatsViewController () {
    NSMutableArray *_paths;
}
@end

@implementation StatsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Stats";
        self.tabBarItem.title = @"Stats";
        self.tabBarItem.image = [UIImage imageNamed:@"stats"];
    }
    return self;
}

- (void)dealloc {
    [_paths release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Load the list of folder files
    [_paths release];
    _paths = [[AppDelegate folderPaths] mutableCopy];

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
    NSString *folderName = [[path lastPathComponent] stringByDeletingPathExtension];
    cell.textLabel.text = folderName;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *folderPath = [_paths objectAtIndex:indexPath.row];

    // Load the route
    Folder *folder = [NSKeyedUnarchiver unarchiveObjectWithFile:folderPath];
    if (folder != nil) {
        // Push on a folder details view
        StatsAvgDurationViewController *statsAvgDurationViewController = [[[StatsAvgDurationViewController alloc] init] autorelease];
        statsAvgDurationViewController.folder = folder;
        [self.navigationController pushViewController:statsAvgDurationViewController animated:YES];
    }
}

@end

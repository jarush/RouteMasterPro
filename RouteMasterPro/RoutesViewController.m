//
//  RoutesViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RoutesViewController.h"

@interface RoutesViewController () {
    NSArray *_files;
}
@end

@implementation RoutesViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Routes";
    }
    return self;
}

- (void)dealloc {
    [_files release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *contentsOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith[c] '.xml'"];
    _files = [[contentsOfDirectory filteredArrayUsingPredicate:predicate] retain];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_files count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [_files objectAtIndex:indexPath.row];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end

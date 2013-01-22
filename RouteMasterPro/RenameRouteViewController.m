//
//  RenameRouteViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/22/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RenameRouteViewController.h"
#import "TextFieldCell.h"

@interface RenameRouteViewController () <UITextFieldDelegate> {
    TextFieldCell *_textFieldCell;
}
@end

@implementation RenameRouteViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Rename";

        UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                       target:self
                                                                                       action:@selector(cancelPressed:)] autorelease];
        self.navigationItem.leftBarButtonItem = cancelButton;

        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(donePressed:)] autorelease];
        self.navigationItem.rightBarButtonItem = doneButton;

        _textFieldCell = [[TextFieldCell alloc] init];
        _textFieldCell.textField.placeholder = @"Name";
        _textFieldCell.textField.delegate = self;
        _textFieldCell.textField.returnKeyType = UIReturnKeyDone;
        [_textFieldCell.textField addTarget:self
                                     action:@selector(donePressed:)
                           forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    return self;
}

- (void)dealloc {
    [_textFieldCell release];
    [super dealloc];
}

- (void)cancelPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)donePressed:(id)sender {
    if ([_textFieldCell.textField.text length] != 0) {
        [_route rename:_textFieldCell.textField.text];

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setRoute:(Route *)route {
    [_route release];
    _route = [route retain];

    _textFieldCell.textField.text = _route.name;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Enter a new name for the route";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _textFieldCell;
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField.text length] != 0;
}

@end

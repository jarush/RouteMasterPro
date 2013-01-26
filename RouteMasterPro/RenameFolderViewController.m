//
//  RenameFolderViewController.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/26/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "RenameFolderViewController.h"
#import "TextFieldCell.h"

@interface RenameFolderViewController () <UITextFieldDelegate> {
    TextFieldCell *_textFieldCell;
}
@end

@implementation RenameFolderViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Rename Folder";

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
        [_folder rename:_textFieldCell.textField.text];

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setFolder:(Folder *)folder {
    [_folder release];
    _folder = [folder retain];

    _textFieldCell.textField.text = _folder.name;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Enter a new name for the folder";
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

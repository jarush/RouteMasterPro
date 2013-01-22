//
//  TextFieldCell.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/22/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "TextFieldCell.h"

#define kXMargin 10.0
#define kYMargin 1.0

@implementation TextFieldCell

@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textField = [[UITextField alloc] init];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        
        [self.contentView addSubview:_textField];
    }
    return self;
}

- (void)dealloc {
    [_textField release];
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _textField.frame =  CGRectInset(self.contentView.bounds, kXMargin, kYMargin);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        [_textField becomeFirstResponder];
    }
}

@end

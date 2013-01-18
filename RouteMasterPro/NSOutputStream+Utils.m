//
//  NSOutputStream+Utils.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/18/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "NSOutputStream+Utils.h"

@implementation NSOutputStream (Utils)

- (NSInteger)writeString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self write:data.bytes maxLength:data.length];
}

@end

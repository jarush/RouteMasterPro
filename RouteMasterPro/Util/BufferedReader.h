//
//  BufferedReader.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/16/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BufferedReader : NSObject

- (id)initWithInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize encoding:(NSStringEncoding)encoding;
- (id)initWithInputStream:(NSInputStream *)inputStream;

- (NSString *)readLine;

@end

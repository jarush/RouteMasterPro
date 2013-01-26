//
//  BufferedReader.m
//  RouteMasterPro
//
//  Created by Jason Rush on 1/16/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "BufferedReader.h"

#define DEFAULT_SIZE 1024

@interface BufferedReader () {
    NSInputStream *_inputStream;

    NSUInteger _bufferSize;
    uint8_t *_buffer;
    NSInteger _offset;
    NSInteger _nbytes;

    NSStringEncoding _encoding;
    NSMutableData *_lineBuffer;
}

@end

@implementation BufferedReader

- (id)initWithInputStream:(NSInputStream *)inputStream bufferSize:(NSUInteger)bufferSize encoding:(NSStringEncoding)encoding {
    self = [super init];
    if (self) {
        _inputStream = [inputStream retain];

        _bufferSize = bufferSize;
        _buffer = malloc(bufferSize);
        _offset = 0;
        _nbytes = 0;

        _encoding = encoding;
        _lineBuffer = [[NSMutableData alloc] initWithCapacity:bufferSize];
    }
    return self;
}

- (id)initWithInputStream:(NSInputStream *)inputStream {
    return [self initWithInputStream:inputStream bufferSize:DEFAULT_SIZE encoding:NSUTF8StringEncoding];
}

- (void)dealloc {
    [_inputStream release];
    free(_buffer);
    [_lineBuffer release];
    [super dealloc];
}

- (NSString *)readLine {
    BOOL foundLine = NO;
    NSInteger n;
    NSInteger i;

    // Clear out the line buffer
    [_lineBuffer setLength:0];

    do {
        // Check if we have any bytes to process
        if (_offset >= _nbytes) {
            _offset = 0;
            _nbytes = 0;

            // Read some more data from the input stream
            n = [_inputStream read:_buffer maxLength:_bufferSize];
            if (n <= 0) {
                break;
            }

            _nbytes = n;
        }

        // Search for a newline in the buffer
        NSInteger index = -1;
        for (i = _offset; i < _nbytes; i++) {
            if (_buffer[i] == '\n') {
                foundLine = YES;
                index = i + 1;
                break;
            }
        }

        // Add the bytes up to the newline or the end of the buffer if no newline was found
        n = (foundLine ? index : _nbytes) - _offset;
        [_lineBuffer appendBytes:(_buffer + _offset) length:n];
        _offset += n;
    } while (!foundLine);

    // If we didn't find a line return nil to signal EOF
    if (_lineBuffer.length == 0) {
        return nil;
    }

    // Decode the bytes into the string
    NSString *line = [[[NSString alloc] initWithBytes:_lineBuffer.bytes length:_lineBuffer.length encoding:_encoding] autorelease];

    // Return a string with the newlines trimmed
    return [line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]];
}

@end

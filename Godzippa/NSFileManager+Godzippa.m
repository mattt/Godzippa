// NSFileManager+Godzippa.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSFileManager+Godzippa.h"

#import <zlib.h>

@implementation NSFileManager (Godzippa)

-(void)gzipCompressWithSourceFilePath:(NSString *)sourcePath
                toDestinationFilePath:(NSString *)destinationPath
                                error:(NSError *__autoreleasing *)error
{
    [self gzipCompressWithSourceFilePath:sourcePath
                   toDestinationFilePath:destinationPath
                                   level:Z_DEFAULT_COMPRESSION
                                   error:error];
}

-(void)gzipCompressWithSourceFilePath:(NSString *)sourcePath
                toDestinationFilePath:(NSString *)destinationPath
                                level:(int)level
                                error:(NSError *__autoreleasing *)error
{
    NSDictionary *sourceAttrs = [self attributesOfItemAtPath:sourcePath error:error];
    if ([sourceAttrs[NSFileSize] isEqualTo:@0]) {
        return;
    }
    
    NSFileHandle *sourceFileHandle = [NSFileHandle fileHandleForReadingAtPath:sourcePath];
    NSUInteger bufferSize = 4096;
    NSData *data = [sourceFileHandle readDataOfLength:bufferSize];
    
    const char* mode = NULL;
    if (level == Z_DEFAULT_COMPRESSION) {
        mode = "w";
    } else {
        mode = [NSString stringWithFormat:@"w%d", level].UTF8String;
    }
    gzFile fileOutput = gzopen(destinationPath.UTF8String, mode);
    while (data.length > 0) @autoreleasepool {
        gzwrite(fileOutput, data.bytes, (unsigned) data.length);
        data = [sourceFileHandle readDataOfLength:bufferSize];
    }
    gzclose(fileOutput);
    
    [sourceFileHandle closeFile];
}

-(void)gzipDecompressWithSourceFilePath:(NSString *)sourcePath
                  toDestinationFilePath:(NSString *)destinationPath
                                  error:(NSError *__autoreleasing *)error
{
    NSDictionary *sourceAttrs = [self attributesOfItemAtPath:sourcePath error:error];
    if ([sourceAttrs[NSFileSize] isEqualTo:@0]) {
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [[NSFileManager defaultManager] createFileAtPath:destinationPath
                                                contents:nil
                                              attributes:nil];
    }
    NSFileHandle *destinationFileHandle = [NSFileHandle fileHandleForWritingAtPath:destinationPath];
    unsigned bufferSize = 4096;
    char buffer[4096];
    gzFile fileInput = gzopen(sourcePath.UTF8String, "r");
    int read;
    while ((read = gzread(fileInput, buffer, bufferSize)) > 0) @autoreleasepool {
        [destinationFileHandle writeData:[NSData dataWithBytes:buffer length:read]];
    }
    gzclose(fileInput);
    [destinationFileHandle synchronizeFile];
    [destinationFileHandle closeFile];
}

@end

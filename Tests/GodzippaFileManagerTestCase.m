// GodzippaFileManagerTestCase.m
// Copyright (c) 2013 Mattt Thompson (http://mattt.me/)
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

#import "Godzippa.h"

#import <XCTest/XCTest.h>

@interface GodzippaFileManagerTestCase : XCTestCase
@property (nonatomic, copy) NSData *data;
@property (nonatomic, copy) NSURL *compressedFileURL;
@property (nonatomic, copy) NSURL *decompressedFileURL;
@end

@implementation GodzippaFileManagerTestCase

- (void)setUp {
    [super setUp];

    self.compressedFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"compressed.gzip"]];
    self.decompressedFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"decompressed"]];

    self.data = [@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)tearDown {
    if (self.compressedFileURL && [[NSFileManager defaultManager] fileExistsAtPath:self.compressedFileURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:self.compressedFileURL error:nil];
    }

    if (self.decompressedFileURL && [[NSFileManager defaultManager] fileExistsAtPath:self.decompressedFileURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:self.decompressedFileURL error:nil];
    }

    [super tearDown];
}

#pragma mark -

- (void)testCompressFile {
    [self.data writeToURL:self.decompressedFileURL atomically:YES];

    NSError *error = nil;
    [[NSFileManager defaultManager] GZipCompressFile:self.decompressedFileURL writingContentsToFile:self.compressedFileURL error:&error];
    XCTAssertNil(error, @"error should be nil");

    NSData *compressedData = [self.data dataByGZipCompressingWithError:nil];
    NSDictionary *compressedFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.compressedFileURL.path error:nil];

    XCTAssertEqualObjects(@(compressedData.length), compressedFileAttributes[NSFileSize], @"compressed file size doesn't equal expected size");
    XCTAssertEqualObjects(compressedData, [NSData dataWithContentsOfURL:self.compressedFileURL], @"compressed data is not equal");
}

- (void)testDecompressFile {
    NSData *compressedData = [self.data dataByGZipCompressingWithError:nil];
    [compressedData writeToURL:self.compressedFileURL atomically:YES];

    NSError *error = nil;
    [[NSFileManager defaultManager] GZipDecompressFile:self.compressedFileURL writingContentsToFile:self.decompressedFileURL error:&error];
    XCTAssertNil(error, @"error should be nil");

    NSDictionary *decompressedFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.decompressedFileURL.path error:nil];

    XCTAssertEqualObjects(@(self.data.length), decompressedFileAttributes[NSFileSize], @"decompressed file size doesn't equal expected size");
    XCTAssertEqualObjects(self.data, [NSData dataWithContentsOfURL:self.decompressedFileURL], @"decompressed data is not equal");
}

@end

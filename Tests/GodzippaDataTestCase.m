// GodzippaTest.h
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

@interface GodzippaDataTestCase : XCTestCase
@property (nonatomic, copy) NSData *data;
@end

@implementation GodzippaDataTestCase

- (void)setUp {
    [super setUp];

    self.data = [@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -

- (void)testCompressionOfData {
    NSError *error = nil;
	[self.data dataByGZipCompressingWithError:&error];

	XCTAssertNil(error, @"Error compressing data: %@", [error localizedDescription]);
}

- (void)testCompressionOfEmptyDataIsEmpty {
	NSData *compressedData = [[NSData data] dataByGZipCompressingWithError:nil];
    XCTAssertTrue([[NSData data] isEqualToData:compressedData], @"compression of empty data is not empty");
}

- (void)testDecompressionOfCompressedData {
    NSError *error = nil;
    [[self.data dataByGZipCompressingWithError:&error] dataByGZipDecompressingDataWithError:&error];

	XCTAssertNil(error, @"Error compressing data: %@", [error localizedDescription]);
}

- (void)testEqualityForDecompressionOfCompressedData {
    NSData *compressedData = [self.data dataByGZipCompressingWithError:nil];
	NSData *decompressedData = [compressedData dataByGZipDecompressingDataWithError:nil];

    XCTAssertNotNil(self.data, @"compressed data is nil");
	XCTAssertTrue([self.data isEqualToData:decompressedData], @"decompression of compressed data not same as original");
}

@end

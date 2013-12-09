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

#import "GodzippaTest.h"

#import "NSData+Godzippa.h"

@interface GodzippaTest ()
@property (readwrite, nonatomic, copy) NSData *data;
@end

@implementation GodzippaTest

- (void)setUp {
    [super setUp];

    self.data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"txt"]];
}

- (void)testCompressionOfData {
    NSError *error = nil;
	[self.data dataByGZipCompressingWithError:&error];

	STAssertNil(error, @"Error compressing data: %@", [error localizedDescription]);
}

- (void)testCompressionOfEmptyDataIsEmpty {
	NSData *compressedData = [[NSData data] dataByGZipCompressingWithError:nil];
    STAssertTrue([[NSData data] isEqualToData:compressedData], @"compression of empty data is not empty");
}

- (void)testDecompressionOfCompressedData {
    NSError *error = nil;
    [[self.data dataByGZipCompressingWithError:&error] dataByGZipDecompressingDataWithError:&error];

	STAssertNil(error, @"Error compressing data: %@", [error localizedDescription]);
}

- (void)testEqualityForDecompressionOfCompressedData {
    NSData *compressedData = [self.data dataByGZipCompressingWithError:nil];
	NSData *decompressedData = [compressedData dataByGZipDecompressingDataWithError:nil];

    STAssertNotNil(self.data, @"compressed data is nil");
	STAssertTrue([self.data isEqualToData:decompressedData], @"decompression of compressed data not same as original");
}

@end

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
@property (readwrite, nonatomic, copy) NSString *path;
@property (readwrite, nonatomic, copy) NSData *data;
@end

@implementation GodzippaTest

- (void)setUp {
    [super setUp];

    self.path = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"txt"];
    self.data = [NSData dataWithContentsOfFile:self.path];
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

- (void)testCompressFile {
    NSData *compressedData = [self.data dataByGZipCompressingWithError:nil];
    
    NSString *compressedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"compressed.gzip"];
    [[NSFileManager defaultManager] gzipCompressWithSourceFilePath:self.path
                                             toDestinationFilePath:compressedFilePath
                                                             error:nil];
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:compressedFilePath
                                                                          error:nil];
    
    STAssertEqualObjects(attr[NSFileSize], @(compressedData.length), @"compressed file size doesn't match with the expected size");
    STAssertEqualObjects(compressedData, [NSData dataWithContentsOfFile:compressedFilePath], @"");
    
    [[NSFileManager defaultManager] removeItemAtPath:compressedFilePath
                                               error:nil];
}

- (void)testDecompressFile {
    NSString *compressedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"compressed.gzip"];
    [[NSFileManager defaultManager] gzipCompressWithSourceFilePath:self.path
                                             toDestinationFilePath:compressedFilePath
                                                             error:nil];
    
    NSString *uncompressedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"uncompressed.gzip"];
    [[NSFileManager defaultManager] gzipDecompressWithSourceFilePath:compressedFilePath
                                               toDestinationFilePath:uncompressedFilePath
                                                               error:nil];
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:uncompressedFilePath
                                                                          error:nil];
    
    STAssertEqualObjects(attr[NSFileSize], @(self.data.length), @"");
    STAssertEqualObjects(self.data, [NSData dataWithContentsOfFile:uncompressedFilePath], @"");
    
    [[NSFileManager defaultManager] removeItemAtPath:compressedFilePath
                                               error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:uncompressedFilePath
                                               error:nil];
}

@end

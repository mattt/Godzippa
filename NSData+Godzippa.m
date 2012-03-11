// NSData+Godzippa.m
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

#import "NSData+Godzippa.h"

#import <zlib.h>

NSString * const GodzippaZlibErrorDomain = @"com.godzippa.zlib.error";

@implementation NSData (Godzippa)

- (NSData *)dataByGZipCompressingWithError:(NSError **)error {
	if ([self length] == 0) {
		return self;
	}
    
	z_stream zStream;
    
	zStream.zalloc = Z_NULL;
	zStream.zfree = Z_NULL;
	zStream.opaque = Z_NULL;
	zStream.next_in = (Bytef *)[self bytes];
	zStream.avail_in = [self length];
	zStream.total_out = 0;
    
	if (deflateInit(&zStream, Z_DEFAULT_COMPRESSION) != Z_OK) {
		return nil;
	}
    
	NSUInteger compressionChunkSize = 16384; // 16Kb
	NSMutableData *compressedData = [NSMutableData dataWithLength:compressionChunkSize];
    
	do {
		if (zStream.total_out >= [compressedData length]) {
			[compressedData increaseLengthBy:compressionChunkSize];
		}
        
		zStream.next_out = [compressedData mutableBytes] + zStream.total_out;
		zStream.avail_out = [compressedData length] - zStream.total_out;
        
		deflate(&zStream, Z_FINISH);
        
	} while (zStream.avail_out == 0);
    
	deflateEnd(&zStream);
	[compressedData setLength:zStream.total_out];
    
	return [NSData dataWithData:compressedData];
}

- (NSData *)dataByGZipDecompressingDataWithError:(NSError **)error {
    z_stream zStream;
    
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.next_in = (Bytef *)[self bytes];
    zStream.avail_in = [self length];
    zStream.avail_out = 0;
    zStream.total_out = 0;
    
    NSUInteger estimatedLength = [self length] / 2;
    NSMutableData *decompressedData = [NSMutableData dataWithLength:estimatedLength];
    
	do {
		if (zStream.total_out >= [decompressedData length]) {
            [decompressedData increaseLengthBy:estimatedLength / 2];
		}
        
		zStream.next_out = [decompressedData mutableBytes] + zStream.total_out;
		zStream.avail_out = [decompressedData length] - zStream.total_out;
        
		int status = inflate(&zStream, Z_FINISH);
        
		if (status == Z_STREAM_END) {
			break;
		} else if (status != Z_OK) {
            if (error) {
                *error = [NSError errorWithDomain:GodzippaZlibErrorDomain code:status userInfo:nil];
            }
            
			return nil;
		}
	} while (zStream.avail_out == 0);
    
	[decompressedData setLength:zStream.total_out];
    
	return [NSData dataWithData:decompressedData];
}

@end

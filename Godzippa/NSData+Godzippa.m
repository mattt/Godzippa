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

static NSUInteger const kGodzippaChunkSize = 1024;

NSString * const GodzippaZlibErrorDomain = @"com.godzippa.zlib.error";

@implementation NSData (Godzippa)

- (NSData *)dataByGZipCompressingWithError:(NSError **)error {
	if ([self length] == 0) {
		return self;
	}
    
	z_stream zStream;
    bzero(&zStream, sizeof(z_stream));

	zStream.zalloc = Z_NULL;
	zStream.zfree = Z_NULL;
	zStream.opaque = Z_NULL;
	zStream.next_in = (Bytef *)[self bytes];
	zStream.avail_in = (unsigned int)[self length];
	zStream.total_out = 0;

    OSStatus status;
	if ((status = deflateInit(&zStream, Z_DEFAULT_COMPRESSION)) != Z_OK) {
		if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed deflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
	}
    
	NSMutableData *compressedData = [NSMutableData dataWithLength:kGodzippaChunkSize];
    
	do {
		if (zStream.total_out >= [compressedData length]) {
			[compressedData increaseLengthBy:kGodzippaChunkSize];
		}
        
		zStream.next_out = [compressedData mutableBytes] + zStream.total_out;
		zStream.avail_out = (unsigned int)([compressedData length] - zStream.total_out);
        
		status = deflate(&zStream, Z_FINISH);
	} while (status == Z_OK);
    
	deflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error deflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }

    [compressedData setLength:zStream.total_out];
    
	return [NSData dataWithData:compressedData];
}

- (NSData *)dataByGZipDecompressingDataWithError:(NSError **)error {
    if ([self length] == 0) {
		return self;
	}

    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));

    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.avail_in = (unsigned int)[self length];
    zStream.next_in = (Byte *)[self bytes];

    NSUInteger estimatedLength = [self length] * 4;
    NSMutableData *decompressedData = [NSMutableData dataWithCapacity:estimatedLength];

    OSStatus status;
    if ((status = inflateInit(&zStream)) != Z_OK) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed inflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }

    do {
        zStream.avail_out = kGodzippaChunkSize;
        zStream.next_out = [decompressedData mutableBytes];
        
        status = inflate(&zStream, Z_NO_FLUSH);
    } while (status == Z_OK);

    inflateEnd(&zStream);

    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error inflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }
    
    return decompressedData;
}

@end

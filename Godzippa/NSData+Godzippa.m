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

static const int DEFAULT_MEM_LEVEL = 8;
static const int DEFAULT_WINDOW_BITS = 15;
static const int DEFAULT_WINDOW_BIT_USE_GZIP_HEADER = 16;
static const int DEFAULT_WINDOW_BITS_WITH_GZIP_HEADER = DEFAULT_WINDOW_BITS + DEFAULT_WINDOW_BIT_USE_GZIP_HEADER;

NSString * const GodzippaZlibErrorDomain = @"com.godzippa.zlib.error";

@implementation NSData (Godzippa)

- (NSData *)dataByGZipCompressingWithError:(NSError **)error {
	return [self dataByGZipCompressingUsingGzipHeader:NO error:error];
}

- (NSData *)dataByGZipCompressingUsingGzipHeader:(BOOL)useHeader error:(NSError **)error {
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
    if (useHeader)
    {
        status = deflateInit(&zStream, Z_DEFAULT_COMPRESSION);
    }
    else
    {
        status = deflateInit2(&zStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, DEFAULT_WINDOW_BITS_WITH_GZIP_HEADER, DEFAULT_MEM_LEVEL, Z_DEFAULT_STRATEGY);
    }
	if (status != Z_OK) {
		if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed deflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
	}
    
	NSMutableData *compressedData = [NSMutableData dataWithLength:kGodzippaChunkSize];
    
	do {
		if ((status == Z_BUF_ERROR) || (zStream.total_out == [compressedData length])) {
			[compressedData increaseLengthBy:kGodzippaChunkSize];
		}
        
		zStream.next_out = [compressedData mutableBytes] + zStream.total_out;
		zStream.avail_out = (unsigned int)([compressedData length] - zStream.total_out);
        
		status = deflate(&zStream, Z_FINISH);
	} while ((status == Z_OK) || (status == Z_BUF_ERROR));
    
	deflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error deflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }

    [compressedData setLength:zStream.total_out];
    
	return compressedData;
}

- (NSData *)dataByGZipDecompressingDataWithError:(NSError **)error {
    return [self dataByGZipDecompressingDataUsingGzipHeader:NO error:error];
}

- (NSData *)dataByGZipDecompressingDataUsingGzipHeader:(BOOL)useHeader error:(NSError **)error {
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

    OSStatus status;
    if (useHeader)
    {
        status = inflateInit(&zStream);
    }
    else
    {
        status = inflateInit2(&zStream, DEFAULT_WINDOW_BITS_WITH_GZIP_HEADER);
    }
    if (status != Z_OK) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed inflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }

    NSUInteger estimatedLength = [self length] * 1.5;
    NSMutableData *decompressedData = [NSMutableData dataWithLength:estimatedLength];
    
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [decompressedData length])) {
            [decompressedData increaseLengthBy:estimatedLength / 2];
        }
        
        zStream.next_out = [decompressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([decompressedData length] - zStream.total_out);
        
        status = inflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));

    inflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error inflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:GodzippaZlibErrorDomain code:status userInfo:userInfo];
        }

        return nil;
    }
    
    [decompressedData setLength:zStream.total_out];
    
    return decompressedData;
}

@end

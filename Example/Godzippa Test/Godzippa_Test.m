#import "Godzippa_Test.h"

#import "NSData+Godzippa.h"

@implementation Godzippa_Test

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
	NSString* testTxt = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"txt"];
	NSData* testTxtData = [NSData dataWithContentsOfFile:testTxt];

	NSError* error = nil;

	NSData* compressedData = [testTxtData dataByGZipCompressingWithError:&error];
	STAssertNil(error, @"Error compressing data: %@", [error localizedDescription]);

	NSData* decompressedData = [compressedData dataByGZipDecompressingDataWithError:&error];
	STAssertNil(error, @"Error decompressing data: %@", [error localizedDescription]);
	STAssertTrue([testTxtData isEqualToData:decompressedData], @"Decompression test failed");
}

@end

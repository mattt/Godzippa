# Godzippa!
**gzip Compression / Decompression Category for NSData & NSFileManager**

## Example Usage

### NSData

```objective-c
NSData *originalData = [@"Look out! It's..." dataUsingEncoding:NSUTF8StringEncoding];
NSData *compressedData = [originalData dataByGZipCompressingWithError:nil];
NSData *decompressedData = [compressedData dataByGZipDecompressingDataWithError:nil];
NSLog(@"%@ %@", [NSString stringWithUTF8String:[decompressedData bytes]], @"Godzippa!");
```

### NSFileManager

```objective-c
NSFileManager *fileManager = [NSFileManager defaultManager];
NSURL *file = [NSURL fileURLWithPath:@"/path/to/file.txt"];
NSError *error = nil;

[fileManager GZipCompressFile:file
        writingContentsToFile:[file URLByAppendingPathExtension:@"gz"]
                        error:&error];
```

## Requirements

- **zlib** - In the "Link Binary With Libraries" Build Phase of your Target, add `libz.dylib`

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Godzippa! is available under the MIT license. See the LICENSE file for more info.

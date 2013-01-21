# Godzippa!
**gzip Compression / Decompression Category for NSData**

## Example Usage

``` objective-c
NSData *originalData = [@"Look out! It's..." dataUsingEncoding:NSUTF8StringEncoding];
NSData *compressedData = [originalData dataByGZipCompressingWithError:nil];
NSData *decompressedData = [compressedData dataByGZipDecompressingDataWithError:nil];
NSLog(@"%@ %@", [NSString stringWithUTF8String:[decompressedData bytes]], @"Godzippa!");
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

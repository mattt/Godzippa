```
                       _     _                   _ 
                      | |   (_)                 | |
        __ _  ___   __| |_____ _ __  _ __   __ _| |
       / _` |/ _ \ / _` |_  / | '_ \| '_ \ / _` | |
      | (_| | (_) | (_| |/ /| | |_) | |_) | (_| |_|
       \__, |\___/ \__,_/___|_| .__/| .__/ \__,_(_)
        __/ |                 | |   | |            
       |___/                  |_|   |_|            
```

# Godzippa! - GZip Compression / Decompression Category for NSData

## Example Usage
``` objective-c
NSData *originalData = [@"Look out! It's..." dataUsingEncoding:NSUTF8StringEncoding];
NSData *compressedData = [data dataByGZipCompressingWithError:nil];
NSData *decompressedData = [compressedData dataByGZipDecompressingDataWithError:nil];
NSLog(@"%@", [NSString stringWithUTF8String:[decompressedData bytes]]);
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

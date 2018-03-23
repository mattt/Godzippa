import Foundation
import Godzippa

let originalString = "Look out! It's Godzippa!"
let originalData = originalString.data(using: .utf8) as! NSData
let compressedData = try! originalData.gzipCompressed() as! NSData
let decompressedData = try! compressedData.gzipDecompressed()
let decompressedString = String(data: decompressedData, encoding: .utf8)

originalString == decompressedString

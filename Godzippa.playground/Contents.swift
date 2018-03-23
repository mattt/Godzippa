import Foundation
import Godzippa

let originalString = "Look out! It's Godzippa!"
let originalData = originalString.data(using: .utf8) as! NSData
let compressedData = try! originalData.byGZipCompressing() as! NSData
let decompressedData = try! compressedData.byGZipDecompressingData()
let decompressedString = String(data: decompressedData, encoding: .utf8)

originalString == decompressedString

import Foundation
import Godzippa

let originalString = "Look out! It's Godzippa!"
let originalData = originalString.data(using: .utf8)! as NSData
let compressedData = try! originalData.gzipCompressed() as NSData
let decompressedData = try! compressedData.gzipDecompressed()
let decompressedString = String(data: decompressedData, encoding: .utf8)

originalString == decompressedString


let fileManager = FileManager.default
guard let textFile = Bundle.main.url(forResource: "file", withExtension: "txt") else {
    fatalError("Missing resource: file.txt")
}
print("Compressed: \(try fileSize(of: textFile))")

let gzipFile = textFile.appendingPathExtension("gz")
try fileManager.gzipCompressFile(at: textFile, to: gzipFile)
print("Decompressed: \(try fileSize(of: gzipFile))")

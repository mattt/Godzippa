import Foundation

public func fileSize(of file: URL) throws -> String {
    let fileManager = FileManager.default

    guard fileManager.fileExists(atPath: file.path) else {
        return ""
    }

    let byteCount: Int64
    let attributes = try fileManager.attributesOfItem(atPath: file.path)
    switch attributes[.type] as! FileAttributeType {
    case .typeSymbolicLink:
        let destination = try FileManager.default.destinationOfSymbolicLink(atPath: file.path)
        byteCount = try fileManager.attributesOfItem(atPath: destination)[.size] as! Int64
    case FileAttributeType.typeRegular:
        byteCount = attributes[.size] as! Int64
    default:
        return ""
    }

    return ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
}

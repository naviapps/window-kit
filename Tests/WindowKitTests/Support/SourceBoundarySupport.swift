import Foundation
import XCTest

enum SourceBoundarySupport {
  static func repositoryRoot() -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }

  static func sourceFilesText(relativeRoot: String) throws -> String {
    let sourcesURL = repositoryRoot().appendingPathComponent(relativeRoot)
    if sourcesURL.pathExtension == "swift" {
      return try String(contentsOf: sourcesURL, encoding: .utf8)
    }

    let fileURLs =
      FileManager.default
      .enumerator(at: sourcesURL, includingPropertiesForKeys: nil)?
      .compactMap { $0 as? URL }
      .filter { $0.pathExtension == "swift" } ?? []

    XCTAssertFalse(fileURLs.isEmpty, "\(relativeRoot) should contain source files.")
    return try fileURLs.map { try String(contentsOf: $0, encoding: .utf8) }.joined(separator: "\n")
  }
}

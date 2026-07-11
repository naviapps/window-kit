import CoreGraphics
import Foundation
import os
import WindowKit

@testable import WindowKitAppKit

final class WindowListProviderSpy: WindowListProviding {
  let entries: [WindowListEntry]?
  private let requestsStorage = OSAllocatedUnfairLock(initialState: [WindowListRequest]())

  var requests: [WindowListRequest] {
    requestsStorage.withLock { $0 }
  }

  init(entries: [WindowListEntry]?) {
    self.entries = entries
  }

  func windowList(for request: WindowListRequest) -> [WindowListEntry]? {
    requestsStorage.withLock {
      $0.append(request)
    }
    return entries
  }
}

struct WindowOwnerBundleIdentifierProvidingStub: WindowOwnerBundleIdentifierProviding {
  let bundleIdentifier: String?

  func bundleIdentifier(forProcessIdentifier _: pid_t) -> String? {
    bundleIdentifier
  }
}

func makeWindowEntry(
  layer: Int,
  frame: CGRect,
  ownerProcessIdentifier: Int32?,
  windowIdentifier: UInt32? = 12345
) -> WindowListEntry {
  let processIdentifier = ownerProcessIdentifier.map { pid_t($0) }
  let cgWindowIdentifier = windowIdentifier.map { CGWindowID($0) }

  return WindowListEntry(
    layer: layer,
    frame: frame,
    ownerProcessIdentifier: processIdentifier,
    windowIdentifier: cgWindowIdentifier,
    ownerName: "ExampleApp",
    title: "Main"
  )
}

import AppKit

protocol RunningApplicationChecking: Sendable {
  func isRunningApplication(processIdentifier: pid_t) -> Bool
}

struct NSRunningApplicationChecker: RunningApplicationChecking {
  init() {}

  func isRunningApplication(processIdentifier pid: pid_t) -> Bool {
    NSRunningApplication(processIdentifier: pid) != nil
  }
}

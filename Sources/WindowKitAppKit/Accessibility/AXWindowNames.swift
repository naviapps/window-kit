import ApplicationServices

enum AXWindowAttribute {
  case focusedApplication
  case focusedWindow
  case fullScreen
  case minimized
  case position
  case role
  case size
  case subrole
  case windowIdentifier
  case windows
}

extension AXWindowAttribute {
  var accessibilityName: String {
    switch self {
    case .focusedApplication:
      kAXFocusedApplicationAttribute as String
    case .focusedWindow:
      kAXFocusedWindowAttribute as String
    case .fullScreen:
      "AXFullScreen"
    case .minimized:
      kAXMinimizedAttribute as String
    case .position:
      kAXPositionAttribute as String
    case .role:
      kAXRoleAttribute as String
    case .size:
      kAXSizeAttribute as String
    case .subrole:
      kAXSubroleAttribute as String
    case .windowIdentifier:
      "AXWindowID"
    case .windows:
      kAXWindowsAttribute as String
    }
  }
}

enum AXWindowAction {
  case raise
  case lower
}

extension AXWindowAction {
  var accessibilityName: String {
    switch self {
    case .raise:
      kAXRaiseAction as String
    case .lower:
      "AXLower"
    }
  }
}

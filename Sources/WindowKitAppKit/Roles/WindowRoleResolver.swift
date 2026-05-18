import ApplicationServices

struct WindowRoleResolver: Sendable {
  init() {}

  func resolve(role: String?, subrole: String?) -> WindowRole {
    let roleValue = role ?? ""
    let subroleValue = subrole ?? ""

    if roleValue == AXRoleName.sheet {
      return .sheet
    }
    if roleValue == AXRoleName.popover {
      return .popover
    }
    if roleValue == AXRoleName.panel {
      return .panel
    }

    if roleValue == AXRoleName.window
      && (subroleValue.isEmpty || subroleValue == AXSubroleName.standardWindow)
    {
      return .standard
    }

    if subroleValue == AXSubroleName.floatingWindow
      || subroleValue == AXSubroleName.systemFloatingWindow
    {
      return .panel
    }
    if subroleValue == AXSubroleName.systemDialog {
      return .systemDialog
    }
    if subroleValue == AXSubroleName.dialog {
      return .dialog
    }

    return .unknown(role: role, subrole: subrole)
  }
}

private enum AXRoleName {
  static let popover = kAXPopoverRole as String
  static let panel = "AXPanel"
  static let sheet = kAXSheetRole as String
  static let window = kAXWindowRole as String
}

private enum AXSubroleName {
  static let dialog = kAXDialogSubrole as String
  static let floatingWindow = kAXFloatingWindowSubrole as String
  static let standardWindow = kAXStandardWindowSubrole as String
  static let systemDialog = kAXSystemDialogSubrole as String
  static let systemFloatingWindow = kAXSystemFloatingWindowSubrole as String
}

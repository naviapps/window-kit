import ApplicationServices

struct WindowRoleResolver: Sendable {
  init() {}

  func resolve(accessibilityRole: String?, accessibilitySubrole: String?) -> WindowRole {
    let roleValue = accessibilityRole.flatMap(AXWindowRoleValue.init(accessibilityName:))
    let subroleValue = accessibilitySubrole.flatMap(AXWindowSubroleValue.init(accessibilityName:))

    switch roleValue {
    case .sheet:
      return .sheet
    case .popover:
      return .popover
    case .panel:
      return .panel
    case .window:
      return resolveWindowSubrole(
        subroleValue,
        accessibilityRole: accessibilityRole,
        accessibilitySubrole: accessibilitySubrole
      )
    case nil:
      return .unclassified(
        accessibilityRole: accessibilityRole,
        accessibilitySubrole: accessibilitySubrole
      )
    }
  }

  private func resolveWindowSubrole(
    _ subroleValue: AXWindowSubroleValue?,
    accessibilityRole: String?,
    accessibilitySubrole: String?
  ) -> WindowRole {
    if accessibilitySubrole != nil && subroleValue == nil {
      return .unclassified(
        accessibilityRole: accessibilityRole,
        accessibilitySubrole: accessibilitySubrole
      )
    }

    switch subroleValue {
    case nil, .standardWindow:
      return .standard
    case .dialog:
      return .dialog
    case .floatingWindow, .systemFloatingWindow:
      return .panel
    case .systemDialog:
      return .systemDialog
    }
  }
}

enum AXWindowRoleValue: Sendable {
  case panel
  case popover
  case sheet
  case window
}

extension AXWindowRoleValue {
  init?(accessibilityName: String) {
    switch accessibilityName {
    case Self.panel.accessibilityName:
      self = .panel
    case Self.popover.accessibilityName:
      self = .popover
    case Self.sheet.accessibilityName:
      self = .sheet
    case Self.window.accessibilityName:
      self = .window
    default:
      return nil
    }
  }

  var accessibilityName: String {
    switch self {
    case .panel:
      "AXPanel"
    case .popover:
      kAXPopoverRole as String
    case .sheet:
      kAXSheetRole as String
    case .window:
      kAXWindowRole as String
    }
  }
}

enum AXWindowSubroleValue: Sendable {
  case dialog
  case floatingWindow
  case standardWindow
  case systemDialog
  case systemFloatingWindow
}

extension AXWindowSubroleValue {
  init?(accessibilityName: String) {
    switch accessibilityName {
    case Self.dialog.accessibilityName:
      self = .dialog
    case Self.floatingWindow.accessibilityName:
      self = .floatingWindow
    case Self.standardWindow.accessibilityName:
      self = .standardWindow
    case Self.systemDialog.accessibilityName:
      self = .systemDialog
    case Self.systemFloatingWindow.accessibilityName:
      self = .systemFloatingWindow
    default:
      return nil
    }
  }

  var accessibilityName: String {
    switch self {
    case .dialog:
      kAXDialogSubrole as String
    case .floatingWindow:
      kAXFloatingWindowSubrole as String
    case .standardWindow:
      kAXStandardWindowSubrole as String
    case .systemDialog:
      kAXSystemDialogSubrole as String
    case .systemFloatingWindow:
      kAXSystemFloatingWindowSubrole as String
    }
  }
}

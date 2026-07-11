import ApplicationServices

@MainActor
struct AXWindowAccess {
  let accessibilityClient: AXClient
  let resolver: AXWindowElementResolver

  static func live() -> AXWindowAccess {
    let accessibilityClient = AXClient.live
    return AXWindowAccess(
      accessibilityClient: accessibilityClient,
      resolver: AXWindowElementResolver(accessibilityClient: accessibilityClient)
    )
  }

  init(
    accessibilityClient: AXClient = .live,
    systemWideElement: AXUIElement,
    applicationChecker: any RunningApplicationChecking =
      NSRunningApplicationChecker(),
    windowListProvider: any WindowListProviding = SystemWindowListProvider()
  ) {
    self.init(
      accessibilityClient: accessibilityClient,
      resolver: AXWindowElementResolver(
        accessibilityClient: accessibilityClient,
        systemWideElement: systemWideElement,
        applicationChecker: applicationChecker,
        windowListProvider: windowListProvider
      )
    )
  }

  private init(accessibilityClient: AXClient, resolver: AXWindowElementResolver) {
    self.accessibilityClient = accessibilityClient
    self.resolver = resolver
  }
}

import CoreGraphics

extension CGRect {
  var finiteStandardized: CGRect {
    if origin.x.isFinite, origin.y.isFinite, width.isFinite, height.isFinite {
      return standardized
    }

    return CGRect(
      x: finiteOrigin(origin.x, offset: width),
      y: finiteOrigin(origin.y, offset: height),
      width: finiteMagnitude(width),
      height: finiteMagnitude(height)
    )
  }

  private func finiteOrigin(_ value: CGFloat, offset: CGFloat) -> CGFloat {
    guard value.isFinite else { return 0 }
    guard offset.isFinite, offset < 0 else { return value }
    return value + offset
  }

  private func finiteMagnitude(_ value: CGFloat) -> CGFloat {
    guard value.isFinite else { return 0 }
    return abs(value)
  }
}

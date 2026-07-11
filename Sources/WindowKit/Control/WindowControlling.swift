/// Complete app-facing contract for reading and controlling a window.
///
/// Consumers that need only one capability should depend on the narrower inherited protocol.
public protocol WindowControlling:
  WindowCommandControlling, WindowFrameControlling, WindowStateProviding
{}

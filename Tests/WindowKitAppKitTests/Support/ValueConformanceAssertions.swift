import XCTest

func assertValueConformance<Value: Codable & Equatable & Hashable>(
  _ value: Value,
  file: StaticString = #filePath,
  line: UInt = #line
) throws {
  let data = try JSONEncoder().encode(value)
  let decoded = try JSONDecoder().decode(Value.self, from: data)

  XCTAssertEqual(decoded, value, file: file, line: line)
  XCTAssertEqual(Set([value, decoded]).count, 1, file: file, line: line)
}

func assertValueConformance<Value: Codable & Equatable & Hashable & Sendable>(
  _: Value.Type,
  _ value: Value,
  file: StaticString = #filePath,
  line: UInt = #line
) throws {
  try assertValueConformance(value, file: file, line: line)
  assertSendable(Value.self)
}

func assertSendable<Value: Sendable>(_: Value.Type) {}

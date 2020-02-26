import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Mongli_ServerTests.allTests),
    ]
}
#endif

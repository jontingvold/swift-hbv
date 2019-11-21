import XCTest


#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HBVTests.allTests),
    ]
}
#endif

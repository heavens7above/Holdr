import XCTest
@testable import Holdr

final class ModelTests: XCTestCase {
    func testHistoryItemCreation() throws {
        let content = "Test Content"
        let item = HistoryItem(content: content, type: .text)
        
        XCTAssertEqual(item.content, content)
        XCTAssertEqual(item.category, .text)
    }
}

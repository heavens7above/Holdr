import XCTest
@testable import Holdr

final class MigrationBenchmarks: XCTestCase {

    private struct LegacyHistoryItem: Codable {
        let id: UUID
        let content: String
        let type: LegacyItemType
        let date: Date
        let appBundleID: String?
        let appName: String?

        enum LegacyItemType: Codable {
            case text
            case link(URL)
            case image(Data)
        }
    }

    func testMigrationSequential() {
        let dummyData = Data(repeating: 0, count: 100_000) // 100KB image
        var items: [LegacyHistoryItem] = []
        for i in 0..<50 {
            items.append(LegacyHistoryItem(id: UUID(), content: "Image \(i)", type: .image(dummyData), date: Date(), appBundleID: nil, appName: nil))
        }

        measure {
            var migratedItems: [HistoryItem] = []
            for legacy in items {
                let type: HistoryItem.ItemType
                switch legacy.type {
                case .text:
                    type = .text
                case .link(let url):
                    type = .link(url)
                case .image(let imageData):
                    if let id = ImageStore.shared.save(data: imageData) {
                        type = .image(id)
                    } else {
                        continue
                    }
                }
                var item = HistoryItem(content: legacy.content, type: type, date: legacy.date, appBundleID: legacy.appBundleID, appName: legacy.appName)
                item.id = legacy.id
                migratedItems.append(item)
            }
        }
    }

    func testMigrationConcurrent() {
        let dummyData = Data(repeating: 0, count: 100_000) // 100KB image
        var items: [LegacyHistoryItem] = []
        for i in 0..<50 {
            items.append(LegacyHistoryItem(id: UUID(), content: "Image \(i)", type: .image(dummyData), date: Date(), appBundleID: nil, appName: nil))
        }

        measure {
            var migratedItemsBuffer = [HistoryItem?](repeating: nil, count: items.count)
            let lock = NSLock()

            DispatchQueue.concurrentPerform(iterations: items.count) { i in
                let legacy = items[i]
                let type: HistoryItem.ItemType
                switch legacy.type {
                case .text:
                    type = .text
                case .link(let url):
                    type = .link(url)
                case .image(let imageData):
                    if let id = ImageStore.shared.save(data: imageData) {
                        type = .image(id)
                    } else {
                        return
                    }
                }
                var item = HistoryItem(content: legacy.content, type: type, date: legacy.date, appBundleID: legacy.appBundleID, appName: legacy.appName)
                item.id = legacy.id

                lock.lock()
                migratedItemsBuffer[i] = item
                lock.unlock()
            }
            _ = migratedItemsBuffer.compactMap { $0 }
        }
    }
}

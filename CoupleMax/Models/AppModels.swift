import Foundation

enum AppTab: Hashable {
    case home
    case recipes
    case wishlist
    case us
}

struct MealRequest: Identifiable, Codable, Equatable {
    let id: UUID
    var dish: String
    var note: String
    var requestedBy: String
    var createdAt: Date
    var isAccepted: Bool

    init(id: UUID = UUID(), dish: String, note: String, requestedBy: String = "绵绵", createdAt: Date = .now, isAccepted: Bool = false) {
        self.id = id
        self.dish = dish
        self.note = note
        self.requestedBy = requestedBy
        self.createdAt = createdAt
        self.isAccepted = isAccepted
    }
}

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var subtitle: String
    var durationMinutes: Int
    var stepCount: Int
    var category: String
    var symbol: String
    var source: String
    var sourceURL: String?

    init(id: UUID = UUID(), title: String, subtitle: String, durationMinutes: Int, stepCount: Int, category: String, symbol: String, source: String, sourceURL: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.durationMinutes = durationMinutes
        self.stepCount = stepCount
        self.category = category
        self.symbol = symbol
        self.source = source
        self.sourceURL = sourceURL
    }
}

struct WishItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var note: String
    var price: String
    var category: String
    var symbol: String
    var source: String
    var sourceURL: String?
    var isRealized: Bool

    init(id: UUID = UUID(), title: String, note: String, price: String, category: String, symbol: String, source: String, sourceURL: String? = nil, isRealized: Bool = false) {
        self.id = id
        self.title = title
        self.note = note
        self.price = price
        self.category = category
        self.symbol = symbol
        self.source = source
        self.sourceURL = sourceURL
        self.isRealized = isRealized
    }
}

enum LinkImportError: LocalizedError {
    case invalidURL

    var errorDescription: String? {
        "这个链接看起来不完整，请重新复制后再试。"
    }
}

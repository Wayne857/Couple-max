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

struct Recipe: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var subtitle: String
    var durationMinutes: Int
    var stepCount: Int
    var category: String
    var symbol: String
    var source: String
    var sourceURL: String?
    var imageURL: String?
    var ingredients: [String]
    var steps: [String]
    var rawText: String?

    init(id: UUID = UUID(), title: String, subtitle: String, durationMinutes: Int, stepCount: Int, category: String, symbol: String, source: String, sourceURL: String? = nil, imageURL: String? = nil, ingredients: [String] = [], steps: [String] = [], rawText: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.durationMinutes = durationMinutes
        self.stepCount = stepCount
        self.category = category
        self.symbol = symbol
        self.source = source
        self.sourceURL = sourceURL
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.steps = steps
        self.rawText = rawText
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, subtitle, durationMinutes, stepCount, category, symbol, source, sourceURL
        case imageURL, ingredients, steps, rawText
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        subtitle = try values.decode(String.self, forKey: .subtitle)
        durationMinutes = try values.decode(Int.self, forKey: .durationMinutes)
        stepCount = try values.decode(Int.self, forKey: .stepCount)
        category = try values.decode(String.self, forKey: .category)
        symbol = try values.decode(String.self, forKey: .symbol)
        source = try values.decode(String.self, forKey: .source)
        sourceURL = try values.decodeIfPresent(String.self, forKey: .sourceURL)
        imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
        ingredients = try values.decodeIfPresent([String].self, forKey: .ingredients) ?? []
        steps = try values.decodeIfPresent([String].self, forKey: .steps) ?? []
        rawText = try values.decodeIfPresent(String.self, forKey: .rawText)
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
    case unsupportedDomain
    case requestFailed
    case accessBlocked
    case contentMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "没有找到有效链接，请完整复制小红书分享内容后再试。"
        case .unsupportedDomain:
            "目前只支持 xhslink.com 和 xiaohongshu.com 的笔记链接。"
        case .requestFailed:
            "小红书页面加载失败，请检查网络或稍后重试。"
        case .accessBlocked:
            "小红书要求安全验证，暂时无法读取这篇笔记。请在小红书中重新生成分享链接后再试。"
        case .contentMissing:
            "链接可以打开，但没有读取到笔记正文；这篇笔记可能已删除、仅自己可见或不是图文笔记。"
        }
    }
}

struct ParsedXiaohongshuRecipe: Equatable, Sendable {
    var title: String
    var text: String
    var imageURL: String?
    var ingredients: [String]
    var steps: [String]
    var resolvedURL: String
}

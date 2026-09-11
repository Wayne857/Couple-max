import Foundation

@MainActor
final class CoupleStore: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published private(set) var mealRequests: [MealRequest]
    @Published private(set) var recipes: [Recipe]
    @Published private(set) var wishes: [WishItem]
    @Published var pendingSharedURL: URL?

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let xiaohongshuParser = XiaohongshuParser()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        mealRequests = Self.load([MealRequest].self, key: "mealRequests", defaults: defaults) ?? [
            MealRequest(dish: "番茄牛腩面", note: "想吃你做的～")
        ]
        recipes = Self.load([Recipe].self, key: "recipes", defaults: defaults) ?? Self.sampleRecipes
        wishes = Self.load([WishItem].self, key: "wishes", defaults: defaults) ?? Self.sampleWishes
    }

    var latestMealRequest: MealRequest? { mealRequests.first }
    var realizedWishCount: Int { wishes.filter(\.isRealized).count }

    func requestMeal(dish: String, note: String) {
        let cleanDish = dish.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanDish.isEmpty else { return }
        mealRequests.insert(MealRequest(dish: cleanDish, note: note), at: 0)
        persist(mealRequests, key: "mealRequests")
    }

    func acceptLatestMeal() {
        guard !mealRequests.isEmpty else { return }
        mealRequests[0].isAccepted = true
        persist(mealRequests, key: "mealRequests")
    }

    func importRecipe(from rawValue: String) async throws {
        let parsed = try await xiaohongshuParser.parse(rawValue)
        let stepCount = max(parsed.steps.count, 1)
        let imported = Recipe(
            title: parsed.title,
            subtitle: parsed.ingredients.isEmpty ? "来自小红书的收藏" : "已整理 \(parsed.ingredients.count) 种食材",
            durationMinutes: min(max(stepCount * 5, 10), 90),
            stepCount: stepCount,
            category: "小红书",
            symbol: "fork.knife",
            source: "小红书",
            sourceURL: parsed.resolvedURL,
            imageURL: parsed.imageURL,
            ingredients: parsed.ingredients,
            steps: parsed.steps,
            rawText: parsed.text
        )
        recipes.insert(imported, at: 0)
        persist(recipes, key: "recipes")
    }

    func importWish(from rawValue: String, note: String) async throws {
        let url = try validatedURL(rawValue)
        try await Task.sleep(for: .milliseconds(850))
        let imported = WishItem(
            title: "双人轻量露营椅",
            note: note.isEmpty ? "想和你一起去露营" : note,
            price: "¥328",
            category: "家居",
            symbol: "tent.fill",
            source: "淘宝",
            sourceURL: url.absoluteString
        )
        wishes.insert(imported, at: 0)
        persist(wishes, key: "wishes")
    }

    func toggleWish(_ id: UUID) {
        guard let index = wishes.firstIndex(where: { $0.id == id }) else { return }
        wishes[index].isRealized.toggle()
        persist(wishes, key: "wishes")
    }

    func receiveSharedURL(_ url: URL) {
        pendingSharedURL = url
        selectedTab = url.host?.contains("taobao") == true || url.host?.contains("tb.cn") == true ? .wishlist : .recipes
    }

    func clearPendingSharedURL() {
        pendingSharedURL = nil
    }

    private func validatedURL(_ value: String) throws -> URL {
        guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme),
              url.host != nil else {
            throw LinkImportError.invalidURL
        }
        return url
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static let sampleRecipes = [
        Recipe(title: "番茄牛腩面", subtitle: "酸甜浓郁", durationMinutes: 32, stepCount: 6, category: "晚餐", symbol: "fork.knife", source: "小红书"),
        Recipe(title: "黄油虾仁滑蛋", subtitle: "嫩滑鲜香", durationMinutes: 15, stepCount: 4, category: "快手菜", symbol: "frying.pan.fill", source: "小红书"),
        Recipe(title: "抹茶巴斯克", subtitle: "周末甜点", durationMinutes: 50, stepCount: 7, category: "甜点", symbol: "birthday.cake.fill", source: "手动创建")
    ]

    private static let sampleWishes = [
        WishItem(title: "HARIO 手冲咖啡壶", note: "想一起喝早咖啡", price: "¥269", category: "家居", symbol: "mug.fill", source: "淘宝"),
        WishItem(title: "复古蓝牙音箱", note: "客厅还缺一点音乐", price: "¥399", category: "家居", symbol: "hifispeaker.fill", source: "淘宝"),
        WishItem(title: "去大理住一周", note: "看风、晒太阳、逛菜市场", price: "2026 秋天", category: "旅行", symbol: "mountain.2.fill", source: "一起计划")
    ]
}

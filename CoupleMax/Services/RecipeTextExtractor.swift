import Foundation

enum RecipeTextExtractor {
    struct Sections: Equatable, Sendable {
        var ingredients: [String]
        var steps: [String]
    }

    static func extract(from text: String) -> Sections {
        let normalized = text
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized
            .components(separatedBy: .newlines)
            .map { clean($0) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }

        var ingredients: [String] = []
        var steps: [String] = []
        var section: Section?

        for line in lines {
            if isIngredientHeader(line) {
                section = .ingredients
                ingredients.append(contentsOf: valuesAfterHeader(line))
                continue
            }
            if isStepHeader(line) {
                section = .steps
                steps.append(contentsOf: valuesAfterHeader(line))
                continue
            }
            switch section {
            case .ingredients:
                if !looksLikeStep(line) { ingredients.append(line) }
                else { section = .steps; steps.append(stripStepPrefix(line)) }
            case .steps:
                steps.append(stripStepPrefix(line))
            case nil:
                if looksLikeStep(line) { steps.append(stripStepPrefix(line)) }
            }
        }

        if steps.isEmpty {
            steps = numberedSegments(in: normalized)
        }
        return Sections(
            ingredients: unique(ingredients).prefix(30).map { $0 },
            steps: unique(steps.filter { $0.count >= 2 }).prefix(20).map { $0 }
        )
    }

    private enum Section { case ingredients, steps }

    private static func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"^[•·\-—]\s*"#, with: "", options: .regularExpression)
    }

    private static func isIngredientHeader(_ value: String) -> Bool {
        ["食材", "用料", "材料", "准备食材"].contains { value.hasPrefix($0) }
    }

    private static func isStepHeader(_ value: String) -> Bool {
        ["步骤", "做法", "制作方法", "开始制作"].contains { value.hasPrefix($0) }
    }

    private static func valuesAfterHeader(_ value: String) -> [String] {
        guard let separator = value.firstIndex(where: { $0 == "：" || $0 == ":" }) else { return [] }
        let tail = String(value[value.index(after: separator)...])
        return tail.components(separatedBy: CharacterSet(charactersIn: "，、;；"))
            .map(clean).filter { !$0.isEmpty }
    }

    private static func looksLikeStep(_ value: String) -> Bool {
        value.range(of: #"^(?:步骤\s*)?(?:\d{1,2}|[一二三四五六七八九十]+)[\.、:：\s]"#, options: .regularExpression) != nil
            || "①②③④⑤⑥⑦⑧⑨⑩".contains(value.first ?? " ")
    }

    private static func stripStepPrefix(_ value: String) -> String {
        value.replacingOccurrences(of: #"^(?:步骤\s*)?(?:\d{1,2}|[一二三四五六七八九十]+)[\.、:：\s]*"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "①②③④⑤⑥⑦⑧⑨⑩ "))
    }

    private static func numberedSegments(in value: String) -> [String] {
        let marker = #"(?:步骤\s*)?(?:\d{1,2}|[一二三四五六七八九十]+)[\.、:：]"#
        let pattern = "(" + marker + #"\s*.*?)(?=\s*"# + marker + "|$)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return []
        }
        let source = value as NSString
        return regex.matches(in: value, range: NSRange(location: 0, length: source.length))
            .compactMap { match -> String? in
                guard match.numberOfRanges > 1 else { return nil }
                return stripStepPrefix(source.substring(with: match.range(at: 1)))
            }
            .map(clean)
            .filter { !$0.isEmpty }
    }

    private static func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}

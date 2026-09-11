import Foundation

struct XiaohongshuParser {
    private let allowedHosts = ["xhslink.com", "xiaohongshu.com"]

    func parse(_ sharedText: String) async throws -> ParsedXiaohongshuRecipe {
        let url = try extractURL(from: sharedText)
        guard isAllowed(url) else {
            throw LinkImportError.unsupportedDomain
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("text/html,application/xhtml+xml", forHTTPHeaderField: "Accept")
        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Version/18.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw LinkImportError.requestFailed
        }

        guard let http = response as? HTTPURLResponse else {
            throw LinkImportError.requestFailed
        }

        if [401, 403, 429].contains(http.statusCode) {
            throw LinkImportError.accessBlocked
        }
        guard (200...299).contains(http.statusCode),
              let finalURL = response.url,
              isAllowed(finalURL),
              let html = decodeHTML(data, response: http) else {
            throw LinkImportError.requestFailed
        }
        if finalURL.path.hasPrefix("/404/sec_") {
            throw LinkImportError.accessBlocked
        }

        return try parseDocument(html: html, resolvedURL: finalURL)
    }

    func parseDocument(html: String, resolvedURL: URL) throws -> ParsedXiaohongshuRecipe {
        let lowercasedHTML = html.lowercased()
        if html.contains("安全验证") || html.contains("验证中心") || lowercasedHTML.contains("captcha") {
            throw LinkImportError.accessBlocked
        }

        let description = cleanText(
            metaValue(named: "og:description", in: html)
                ?? metaValue(named: "description", in: html)
                ?? jsonValue(for: "description", in: html)
                ?? jsonValue(for: "desc", in: html)
                ?? ""
        )
        var title = cleanTitle(
            metaValue(named: "og:title", in: html)
                ?? jsonValue(for: "headline", in: html)
                ?? jsonValue(for: "title", in: html)
                ?? htmlTitle(in: html)
                ?? ""
        )
        if title.isEmpty {
            title = description.components(separatedBy: .newlines).first ?? ""
        }
        let isGenericPage = description.isEmpty && ["小红书", "xiaohongshu"].contains(title.lowercased())
        guard (!title.isEmpty || !description.isEmpty) && !isGenericPage else {
            throw LinkImportError.contentMissing
        }

        let sections = RecipeTextExtractor.extract(from: description)
        return ParsedXiaohongshuRecipe(
            title: title.isEmpty ? "小红书菜谱" : title,
            text: description,
            imageURL: metaValue(named: "og:image", in: html)
                ?? jsonImageURL(in: html),
            ingredients: sections.ingredients,
            steps: sections.steps,
            resolvedURL: resolvedURL.absoluteString
        )
    }

    func extractURL(from text: String) throws -> URL {
        let pattern = #"(?i)(?:https?://)?(?:[a-z0-9-]+\.)*(?:xhslink\.com|xiaohongshu\.com)/[^\s]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            throw LinkImportError.invalidURL
        }
        var value = String(text[range]).trimmingCharacters(in: CharacterSet(charactersIn: "，。；、）】}>\"'"))
        if !value.lowercased().hasPrefix("http://") && !value.lowercased().hasPrefix("https://") {
            value = "https://" + value
        }
        guard var components = URLComponents(string: value), components.host != nil else {
            throw LinkImportError.invalidURL
        }
        if components.scheme?.lowercased() == "http" {
            components.scheme = "https"
        }
        guard let url = components.url else { throw LinkImportError.invalidURL }
        return url
    }

    private func isAllowed(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased(), url.scheme?.lowercased() == "https" else { return false }
        return allowedHosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    private func metaValue(named name: String, in html: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        let patterns = [
            #"<meta[^>]+(?:property|name)=[\"']"# + escaped + #"[\"'][^>]+content=[\"'](.*?)[\"'][^>]*>"#,
            #"<meta[^>]+content=[\"'](.*?)[\"'][^>]+(?:property|name)=[\"']"# + escaped + #"[\"'][^>]*>"#
        ]
        for pattern in patterns {
            if let value = firstCapture(pattern, in: html) { return decoded(value) }
        }
        return nil
    }

    private func htmlTitle(in html: String) -> String? {
        firstCapture(#"<title[^>]*>(.*?)</title>"#, in: html)
    }

    private func jsonValue(for key: String, in html: String) -> String? {
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        guard let captured = firstCapture(#"\""# + escapedKey + #"\"\s*:\s*\"((?:\\.|[^\"\\])*)\""#, in: html) else {
            return nil
        }
        let quoted = "\"" + captured + "\""
        return try? JSONDecoder().decode(String.self, from: Data(quoted.utf8))
    }

    private func jsonImageURL(in html: String) -> String? {
        for key in ["image", "imageUrl", "urlDefault"] {
            if let value = jsonValue(for: key, in: html),
               let url = URL(string: value),
               ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                return value
            }
        }
        return nil
    }

    private func firstCapture(_ pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[range])
    }

    private func decodeHTML(_ data: Data, response _: HTTPURLResponse) -> String? {
        if let value = String(data: data, encoding: .utf8) { return value }
        if let value = String(data: data, encoding: .unicode) { return value }
        return String(data: data, encoding: .isoLatin1)
    }

    private func decoded(_ value: String) -> String {
        value.replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'", options: .caseInsensitive)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)
            .replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
            .replacingOccurrences(of: "<br />", with: "\n", options: .caseInsensitive)
    }

    private func cleanText(_ value: String) -> String {
        decoded(value)
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func cleanTitle(_ value: String) -> String {
        decoded(value)
            .replacingOccurrences(of: " - 小红书", with: "")
            .replacingOccurrences(of: "｜小红书", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

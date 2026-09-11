import Foundation

@main
struct ParserFixtureCheck {
    static func main() throws {
        let html = #"""
        <html><head>
        <meta property="og:title" content="番茄牛腩｜小红书">
        <meta name="description" content="食材：番茄、牛腩、葱&#39;花
        做法：
        1、牛腩焯水后洗净
        2、番茄炒软后加入牛腩炖煮">
        <meta property="og:image" content="https://ci.xiaohongshu.com/cover.jpg">
        </head></html>
        """#

        let parser = XiaohongshuParser()
        let normalizedURL = try parser.extractURL(
            from: "家庭白灼万能公式 http://xhslink.com/o/AgG1bta5QST 复制后打开【小红书】"
        )
        precondition(normalizedURL.absoluteString == "https://xhslink.com/o/AgG1bta5QST")

        let parsed = try parser.parseDocument(
            html: html,
            resolvedURL: URL(string: "https://www.xiaohongshu.com/explore/test")!
        )
        precondition(parsed.title == "番茄牛腩")
        precondition(parsed.ingredients.count == 3)
        precondition(parsed.steps.count == 2)
        precondition(parsed.imageURL == "https://ci.xiaohongshu.com/cover.jpg")

        let genericPage = "<html><head><title>小红书</title></head></html>"
        do {
            _ = try parser.parseDocument(
                html: genericPage,
                resolvedURL: URL(string: "https://www.xiaohongshu.com/404/sec_example")!
            )
            preconditionFailure("Generic security page should not be imported")
        } catch LinkImportError.contentMissing {
            // Expected.
        }

        let oldRecipeJSON = #"{"id":"4EE97420-76F5-4C27-84EF-207B1E18D7A4","title":"旧菜谱","subtitle":"兼容测试","durationMinutes":15,"stepCount":3,"category":"晚餐","symbol":"fork.knife","source":"本地"}"#
        let oldRecipe = try JSONDecoder().decode(Recipe.self, from: Data(oldRecipeJSON.utf8))
        precondition(oldRecipe.ingredients.isEmpty)
        precondition(oldRecipe.steps.isEmpty)
        print("Xiaohongshu parser fixture passed")
    }
}

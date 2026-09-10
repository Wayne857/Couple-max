import SwiftUI

struct RecipeImportSheet: View {
    @EnvironmentObject private var store: CoupleStore
    @Environment(\.dismiss) private var dismiss
    @State private var link = ""
    @State private var isImporting = false
    @State private var errorMessage: String?

    init(initialLink: String = "") {
        _link = State(initialValue: initialLink)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("https://xhslink.com/…", text: $link)
                        .textFieldStyle(.roundedBorder)
                } header: { Text("小红书链接") }
                footer: { Text("会保留原链接，并整理为食材与步骤卡片。") }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("收藏菜谱")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isImporting ? "整理中…" : "解析") { importLink() }
                        .disabled(isImporting || link.isEmpty)
                }
            }
        }
    }

    private func importLink() {
        isImporting = true
        errorMessage = nil
        Task {
            do {
                try await store.importRecipe(from: link)
                store.clearPendingSharedURL()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isImporting = false
            }
        }
    }
}

struct WishImportSheet: View {
    @EnvironmentObject private var store: CoupleStore
    @Environment(\.dismiss) private var dismiss
    @State private var link = ""
    @State private var note = ""
    @State private var isImporting = false
    @State private var errorMessage: String?

    init(initialLink: String = "") {
        _link = State(initialValue: initialLink)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("淘宝商品链接") {
                    TextField("https://m.tb.cn/…", text: $link)
                        .textFieldStyle(.roundedBorder)
                }
                Section("为什么想要它？") {
                    TextField("比如：想和你一起露营", text: $note)
                }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
            }
            .navigationTitle("添加心愿")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isImporting ? "读取中…" : "添加") { importLink() }
                        .disabled(isImporting || link.isEmpty)
                }
            }
        }
    }

    private func importLink() {
        isImporting = true
        errorMessage = nil
        Task {
            do {
                try await store.importWish(from: link, note: note)
                store.clearPendingSharedURL()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isImporting = false
            }
        }
    }
}

import SwiftUI

struct RecipesView: View {
    @EnvironmentObject private var store: CoupleStore
    @State private var search = ""
    @State private var showingImport = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var filteredRecipes: [Recipe] {
        search.isEmpty ? store.recipes : store.recipes.filter { $0.title.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filteredRecipes) { recipe in
                        RecipeCard(recipe: recipe)
                    }
                    Button { showingImport = true } label: {
                        VStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill").font(.largeTitle)
                            Text("从小红书导入").font(.subheadline.bold())
                            Text("粘贴链接，整理做菜步骤").font(.caption2)
                        }
                        .foregroundStyle(Color.coupleRose)
                        .frame(maxWidth: .infinity, minHeight: 205)
                        .background(Color.coupleCream)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .background(Color.couplePaper.ignoresSafeArea())
            .navigationTitle("我们的菜谱")
            .searchable(text: $search, prompt: "搜一道想吃的菜")
            .toolbar {
                Button { showingImport = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showingImport) {
                RecipeImportSheet(initialLink: store.pendingSharedURL?.absoluteString ?? "")
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: store.pendingSharedURL) { _, url in
                if url != nil { showingImport = true }
            }
        }
    }
}

private struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Color.couplePeach.opacity(0.55)
                Image(systemName: recipe.symbol).font(.system(size: 42)).foregroundStyle(Color.coupleRose)
                Text("\(recipe.durationMinutes) 分钟")
                    .font(.caption2.bold()).foregroundStyle(.white)
                    .padding(7).background(.black.opacity(0.55)).clipShape(Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing).padding(8)
            }
            .frame(height: 126)
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title).font(.headline).lineLimit(1)
                Text("\(recipe.subtitle) · \(recipe.stepCount) 个步骤")
                    .font(.caption2).foregroundStyle(.secondary)
                Text(recipe.source).font(.caption2).foregroundStyle(Color.coupleRose)
            }
            .padding([.horizontal, .bottom], 12)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                cover
                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.title).font(.largeTitle.bold())
                    Text(recipe.subtitle).foregroundStyle(.secondary)
                }
                if !recipe.ingredients.isEmpty {
                    detailSection(title: "食材", values: recipe.ingredients, numbered: false)
                }
                if !recipe.steps.isEmpty {
                    detailSection(title: "做法", values: recipe.steps, numbered: true)
                } else if let text = recipe.rawText, !text.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("原笔记").font(.title2.bold())
                        Text(text).font(.body).lineSpacing(5)
                    }
                }
                if let value = recipe.sourceURL, let url = URL(string: value) {
                    Link(destination: url) {
                        Label("在小红书查看原笔记", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.coupleRose)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(20)
        }
        .background(Color.couplePaper.ignoresSafeArea())
    }

    private var cover: some View {
        ZStack {
            Color.couplePeach.opacity(0.45)
            if let value = recipe.imageURL, let url = URL(string: value) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: { ProgressView() }
            } else {
                Image(systemName: recipe.symbol)
                    .font(.system(size: 72))
                    .foregroundStyle(Color.coupleRose)
            }
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }

    private func detailSection(title: String, values: [String], numbered: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold())
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                HStack(alignment: .top, spacing: 12) {
                    Text(numbered ? "\(index + 1)" : "•")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.coupleRose)
                        .frame(width: 24, height: 24)
                        .background(Color.coupleRose.opacity(0.1))
                        .clipShape(Circle())
                    Text(value)
                        .font(.body)
                        .lineSpacing(4)
                    Spacer()
                }
            }
        }
        .modifier(CoupleCard())
    }
}

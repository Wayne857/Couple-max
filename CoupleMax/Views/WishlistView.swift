import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var store: CoupleStore
    @State private var showingImport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    summary
                    ForEach(store.wishes) { wish in
                        WishCard(wish: wish) { store.toggleWish(wish.id) }
                    }
                }
                .padding(20)
            }
            .background(Color.couplePaper.ignoresSafeArea())
            .navigationTitle("心愿清单")
            .toolbar {
                Button { showingImport = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showingImport) {
                WishImportSheet(initialLink: store.pendingSharedURL?.absoluteString ?? "")
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: store.pendingSharedURL) { _, url in
                if url != nil { showingImport = true }
            }
        }
    }

    private var summary: some View {
        HStack(spacing: 28) {
            VStack(alignment: .leading) {
                Text("共同心愿").font(.caption).foregroundStyle(.white.opacity(0.65))
                Text("\(store.wishes.count)").font(.largeTitle.bold()).foregroundStyle(.white)
            }
            VStack(alignment: .leading) {
                Text("已经实现").font(.caption).foregroundStyle(.white.opacity(0.65))
                Text("\(store.realizedWishCount)").font(.largeTitle.bold()).foregroundStyle(.white)
            }
            Spacer()
            Image(systemName: "heart.fill").font(.title).foregroundStyle(Color.coupleRose)
        }
        .padding(20)
        .background(Color.coupleInk.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private struct WishCard: View {
    let wish: WishItem
    let toggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: wish.symbol)
                .font(.title)
                .frame(width: 72, height: 82)
                .background(Color.couplePeach.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 5) {
                Text(wish.source).font(.caption2).foregroundStyle(Color.coupleRose)
                Text(wish.title).font(.headline)
                Text(wish.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                Text(wish.price).font(.subheadline.bold()).foregroundStyle(Color.coupleRose)
            }
            Spacer()
            Button(action: toggle) {
                Image(systemName: wish.isRealized ? "checkmark.circle.fill" : "heart.fill")
                    .foregroundStyle(wish.isRealized ? Color.coupleGreen : Color.coupleRose)
            }
        }
        .modifier(CoupleCard(padding: 12))
    }
}

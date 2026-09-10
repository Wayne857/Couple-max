import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CoupleStore
    @State private var showingOrder = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        SectionTitle(eyebrow: "我们的第 627 天", title: "晚上好，绵绵")
                        Spacer()
                        HStack(spacing: -10) {
                            PartnerAvatar(name: "绵绵", color: .coupleRose)
                            PartnerAvatar(name: "舟舟", color: .coupleGreen)
                        }
                    }
                    HouseCard()
                    mealSection
                    if let request = store.latestMealRequest {
                        MealRequestCard(request: request) { store.acceptLatestMeal() }
                    }
                    wishPreview
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.couplePaper.ignoresSafeArea())
            .sheet(isPresented: $showingOrder) {
                MealOrderSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var mealSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom) {
                SectionTitle(eyebrow: "今晚吃什么", title: "给 TA 点个菜")
                Spacer()
                Button("点菜 ＋") { showingOrder = true }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.coupleRose)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button { showingOrder = true } label: {
                        ZStack(alignment: .bottomLeading) {
                            Image("TomatoNoodles")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 224, height: 150)
                                .clipped()
                            LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .center, endPoint: .bottom)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("绵绵想吃").font(.caption2)
                                Text("番茄牛腩面").font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(14)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    DishTile(symbol: "flame.fill", title: "可乐鸡翅", tint: .couplePeach) { showingOrder = true }
                    DishTile(symbol: "birthday.cake.fill", title: "抹茶巴斯克", tint: .yellow.opacity(0.35)) { showingOrder = true }
                }
            }
        }
    }

    private var wishPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionTitle(eyebrow: "一起收集", title: "最近的小期待")
                Spacer()
                Button { store.selectedTab = .wishlist } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 34, height: 34)
                        .background(Color.coupleCream)
                        .clipShape(Circle())
                }
            }
            HStack(spacing: 14) {
                Image(systemName: "mug.fill")
                    .font(.title2)
                    .frame(width: 54, height: 54)
                    .background(Color.cyan.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 4) {
                    Text("手冲咖啡壶").font(.headline)
                    Text("舟舟收藏自淘宝 · ¥269").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "heart.fill").foregroundStyle(Color.coupleRose)
            }
            .modifier(CoupleCard(padding: 12))
        }
    }
}

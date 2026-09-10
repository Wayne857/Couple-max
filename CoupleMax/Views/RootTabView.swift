import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var store: CoupleStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem { Label("小屋", systemImage: "house.fill") }

            RecipesView()
                .tag(AppTab.recipes)
                .tabItem { Label("菜谱", systemImage: "fork.knife") }

            WishlistView()
                .tag(AppTab.wishlist)
                .tabItem { Label("心愿", systemImage: "heart.fill") }

            ProfileView()
                .tag(AppTab.us)
                .tabItem { Label("我们", systemImage: "person.2.fill") }
        }
        .tint(.coupleRose)
        .preferredColorScheme(.light)
    }
}

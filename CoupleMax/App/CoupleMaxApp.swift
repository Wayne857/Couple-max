import SwiftUI

@main
struct CoupleMaxApp: App {
    @StateObject private var store = CoupleStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .onOpenURL { url in
                    store.receiveSharedURL(url)
                }
        }
    }
}

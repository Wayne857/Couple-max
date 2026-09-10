import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 14) {
                        HStack(spacing: -8) {
                            PartnerAvatar(name: "绵绵", color: .coupleRose)
                            Image(systemName: "heart.fill")
                                .foregroundStyle(Color.coupleRose)
                                .zIndex(1)
                            PartnerAvatar(name: "舟舟", color: .coupleGreen)
                        }
                        Text("绵绵 & 舟舟").font(.title2.bold())
                        Text("从 2025.01.27 开始相爱").font(.caption).foregroundStyle(.secondary)
                        Text("627").font(.system(size: 48, weight: .bold, design: .serif))
                        Text("在一起的日子").font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(28)
                    .background(Color.couplePeach.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    stats
                    settings
                }
                .padding(20)
            }
            .background(Color.couplePaper.ignoresSafeArea())
            .navigationTitle("我们的记录")
        }
    }

    private var stats: some View {
        HStack(spacing: 10) {
            StatCard(symbol: "fork.knife", value: "12", label: "一起做过")
            StatCard(symbol: "gift.fill", value: "3", label: "实现心愿")
            StatCard(symbol: "envelope.fill", value: "18", label: "点菜成功")
        }
    }

    private var settings: some View {
        VStack(spacing: 10) {
            SettingsRow(symbol: "house.fill", title: "布置我们的小屋", detail: "换一个属于你们的样子")
            SettingsRow(symbol: "bell.fill", title: "双人提醒", detail: "点菜和心愿动态")
            SettingsRow(symbol: "link", title: "邀请另一半", detail: "邀请码 520627")
        }
    }
}

private struct StatCard: View {
    let symbol: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: symbol).foregroundStyle(Color.coupleRose)
            Text(value).font(.title3.bold())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .modifier(CoupleCard(padding: 14))
    }
}

private struct SettingsRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(13)
        .background(Color.coupleCream)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

import SwiftUI

struct HouseCard: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [.couplePeach, .coupleCream], startPoint: .top, endPoint: .bottom)
            Image(systemName: "house.lodge.fill")
                .font(.system(size: 106))
                .foregroundStyle(Color.white.opacity(0.95), Color.coupleRose)
                .padding(.bottom, 42)
            Label("舟舟刚刚回到小屋", systemImage: "circle.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.coupleInk)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 12)
        }
        .frame(height: 216)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

struct DishTile: View {
    let symbol: String
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 34))
                Spacer()
                Text(title)
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(Color.coupleInk)
            .padding(14)
            .frame(width: 126, height: 150, alignment: .leading)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

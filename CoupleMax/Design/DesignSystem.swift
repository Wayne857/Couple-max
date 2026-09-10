import SwiftUI

extension Color {
    static let coupleInk = Color(red: 0.18, green: 0.16, blue: 0.15)
    static let couplePaper = Color(red: 1.00, green: 0.98, blue: 0.95)
    static let coupleRose = Color(red: 0.91, green: 0.40, blue: 0.40)
    static let couplePeach = Color(red: 0.96, green: 0.78, blue: 0.70)
    static let coupleCream = Color(red: 0.96, green: 0.92, blue: 0.87)
    static let coupleGreen = Color(red: 0.45, green: 0.59, blue: 0.49)
}

struct CoupleCard: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.coupleInk.opacity(0.07), lineWidth: 1)
            }
            .shadow(color: Color.coupleInk.opacity(0.06), radius: 18, y: 8)
    }
}

extension View {
    func coupleCard(padding: CGFloat = 16) -> some View {
        modifier(CoupleCard(padding: padding))
    }
}

struct SectionTitle: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(eyebrow.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.coupleInk)
        }
    }
}

struct PartnerAvatar: View {
    let name: String
    let color: Color
    var size: CGFloat = 42

    var body: some View {
        Text(String(name.prefix(1)))
            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.couplePaper, lineWidth: 3))
    }
}

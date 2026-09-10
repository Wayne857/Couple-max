import SwiftUI

struct MealRequestCard: View {
    let request: MealRequest
    let accept: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            PartnerAvatar(name: request.requestedBy, color: .coupleRose)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(request.requestedBy) 点了一道菜")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(request.dish).font(.headline)
                Text("“\(request.note)”")
                    .font(.caption)
                    .foregroundStyle(Color.coupleRose)
            }
            Spacer()
            Button(request.isAccepted ? "已接单 ✓" : "接单", action: accept)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(request.isAccepted ? Color.coupleGreen : Color.coupleInk)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(request.isAccepted)
        }
        .modifier(CoupleCard(padding: 14))
    }
}

struct MealOrderSheet: View {
    @EnvironmentObject private var store: CoupleStore
    @Environment(\.dismiss) private var dismiss
    @State private var dish = "番茄牛腩面"
    @State private var note = "想吃你做的～"
    private let suggestions = ["番茄牛腩面", "可乐鸡翅", "虾仁滑蛋"]

    var body: some View {
        NavigationStack {
            Form {
                Section("快捷选择") {
                    Picker("想吃什么", selection: $dish) {
                        ForEach(suggestions, id: \.self) { Text($0) }
                    }
                    TextField("也可以自己写一道菜", text: $dish)
                }
                Section("留句话") {
                    TextField("想对 TA 说什么", text: $note)
                }
            }
            .navigationTitle("给 TA 点个菜")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("送出") {
                        store.requestMeal(dish: dish, note: note)
                        dismiss()
                    }
                    .disabled(dish.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

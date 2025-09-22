import SwiftUI

struct SearchBarButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(Color.purple500)
        }
        .buttonStyle(.plain)
        .padding()
    }
}

#Preview {
    SearchBarButton() {}
        .padding()
}


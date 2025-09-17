import SwiftUI

struct TabBarHiddenKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct TabBarHiddenModifier: ViewModifier {
    let hidden: Bool
    func body(content: Content) -> some View {
        content
            .preference(key: TabBarHiddenKey.self, value: hidden)
            .toolbar(hidden ? .hidden : .visible, for: .tabBar)
    }
}

extension View {
    func tabBarHidden(_ hidden: Bool) -> some View {
        self.modifier(TabBarHiddenModifier(hidden: hidden))
    }
}

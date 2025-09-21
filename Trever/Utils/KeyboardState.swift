import SwiftUI
import Combine

@MainActor
final class KeyboardState: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var height: CGFloat = 0

    private var cancellables: Set<AnyCancellable> = []

    init() {
        let center = NotificationCenter.default
        center.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: center.publisher(for: UIResponder.keyboardDidShowNotification))
            .sink { [weak self] notif in
                guard let self else { return }
                DispatchQueue.main.async {
                    if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.height = frame.height
                    }
                    self.isVisible = true
                }
            }
            .store(in: &cancellables)

        center.publisher(for: UIResponder.keyboardWillHideNotification)
            .merge(with: center.publisher(for: UIResponder.keyboardDidHideNotification))
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isVisible = false
                    self?.height = 0
                }
            }
            .store(in: &cancellables)
    }
}

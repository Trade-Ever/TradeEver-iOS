import SwiftUI

struct CarDetailScreen: View {
    @StateObject private var vm: CarDetailViewModel

    init(vehicleId: Int64) {
        _vm = StateObject(wrappedValue: CarDetailViewModel(vehicleId: vehicleId))
    }

    var body: some View {
        Group {
            if let d = vm.detail {
                CarDetailView(detail: d)
            } else if vm.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = vm.error {
                ContentUnavailableView("로드 실패", systemImage: "exclamationmark.triangle", description: Text(err))
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await vm.load() }
    }
}

#Preview { CarDetailScreen(vehicleId: 1) }


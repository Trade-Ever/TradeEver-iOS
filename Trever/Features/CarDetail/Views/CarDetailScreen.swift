import SwiftUI

struct CarDetailScreen: View {
    @StateObject private var vm: CarDetailViewModel

    init(vehicleId: Int, auctionId: Int? = nil) {
        print("CarDetailScreen 초기화 - vehicleId: \(vehicleId), auctionId: \(auctionId ?? -1)")
        _vm = StateObject(wrappedValue: CarDetailViewModel(vehicleId: vehicleId, auctionId: auctionId))
    }

    var body: some View {
        Group {
            if let d = vm.detail {
                CarDetailView(detail: d)
                    .environmentObject(vm)
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


//
//  ManufacturerViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/21/25.
//

import Foundation
import SwiftUI
import Alamofire

@MainActor
class CarNameViewModel: ObservableObject {
    @Published var carNames: [CarNameInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func fetchCarNames(category: String, manufacturer: String, includeYear: Bool) async {
        guard !isLoading else { return } // 이미 실행중이면 무시
        isLoading = true
        defer { isLoading = false }

        do {
            if includeYear {
                // ApiResponse<[String]>
                let response: ApiResponse<[String]> = try await NetworkManager.shared.request(
                    to: .vehicleNames(manufacturer: manufacturer),
                    parameters: ["category": category],
                    responseType: ApiResponse<[String]>.self
                )
                
                if response.success, let names = response.data {
                    carNames = names.map{ CarNameInfo(carName: $0, count: 0) }
                } else {
                    errorMessage = response.message
                }
            } else {
                // ApiResponse<[CarNameInfo]>
                let response: ApiResponse<[CarNameInfo]> = try await NetworkManager.shared.request(
                    to: .vehicleNames(manufacturer: manufacturer),
                    parameters: ["category": category],
                    responseType: ApiResponse<[CarNameInfo]>.self
                )
                
                if response.success, let names = response.data {
                    carNames = names
                } else {
                    errorMessage = response.message
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

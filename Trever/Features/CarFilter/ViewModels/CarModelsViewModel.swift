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
class CarModelsViewModel: ObservableObject {
    @Published var carModels: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCarModels(category: String, manufacturer: String, carName: String) async {
        guard !isLoading else { return }   // 이미 실행 중이면 무시
        isLoading = true
        defer { isLoading = false }
                
        do {
            let response: ApiResponse<[String]> = try await NetworkManager.shared.request(
                to: .modelNames,
                parameters: [
                    "category": category,
                    "manufacturer": manufacturer,
                    "carName": carName
                ],
                responseType: ApiResponse<[String]>.self
            )
        
            if response.success, let models = response.data {
                carModels = models
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

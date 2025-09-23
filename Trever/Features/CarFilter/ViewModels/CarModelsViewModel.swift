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
    @Published var carModels: [CarModelInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCarModels(category: String, manufacturer: String, carName: String, includeYear: Bool) async {
        guard !isLoading else { return } // 이미 실행 중이면 무시
        isLoading = true
        defer { isLoading = false }
        
        do {
            if includeYear {
                // ApiResponse<[String]>
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
                    carModels = models.map { CarModelInfo(carModel: $0, count: 0) }
                } else {
                    errorMessage = response.message
                }
            } else {
                // ApiResponse<[CarModelInfo]>
                let response: ApiResponse<[CarModelInfo]> = try await NetworkManager.shared.request(
                    to: .vehicleModels(manufacturer: manufacturer, carName: carName),
                    parameters: [
                        "category": category,
                        "manufacturer": manufacturer,
                        "carName": carName
                    ],
                    responseType: ApiResponse<[CarModelInfo]>.self
                )
                
                if response.success, let models = response.data {
                    carModels = models
                } else {
                    errorMessage = response.message
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


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
class ManufacturerViewModel: ObservableObject {
    @Published var domesticCars: [ManufacturerInfo] = []
    @Published var importedCars: [ManufacturerInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCarManufacturers(includeYear: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            if includeYear {
                // ApiResponse<[String]>
                let response: ApiResponse<[String]> = try await NetworkManager.shared.request(
                    to: .manufacturers,
                    parameters: ["category": "국산"],
                    responseType: ApiResponse<[String]>.self
                )
                
                if response.success, let manufacturers = response.data {
                    domesticCars = manufacturers.map { ManufacturerInfo(manufacturer: $0, count: 0) }
                }
                
                let response2: ApiResponse<[String]> = try await NetworkManager.shared.request(
                    to: .manufacturers,
                    parameters: ["category": "수입"],
                    responseType: ApiResponse<[String]>.self
                )
                
                if response2.success, let manufacturers = response2.data {
                    importedCars = manufacturers.map { ManufacturerInfo(manufacturer: $0, count: 0) }
                }
            } else {
                // ApiResponse<[ManufacturerCategory]>
                let response: ApiResponse<[ManufacturerCategory]> = try await NetworkManager.shared.request(
                    to: .vehicleManufacturers,
                    responseType: ApiResponse<[ManufacturerCategory]>.self
                )
                
                if response.success, let categories = response.data {
                    for category in categories {
                        if category.category == "국산" {
                            domesticCars = category.manufacturers.map {
                                ManufacturerInfo(manufacturer: $0.manufacturer, count: $0.count)
                            }
                        } else if category.category == "수입" {
                            importedCars = category.manufacturers.map {
                                ManufacturerInfo(manufacturer: $0.manufacturer, count: $0.count)
                            }
                        }
                    }
                }
            }
        } catch {
            // 요청이 취소된 경우(사용자가 뒤로가기 등)에는 에러 메시지를 표시하지 않음
            if !error.localizedDescription.contains("Request explicitly canceled") {
                errorMessage = error.localizedDescription
            }
        }
    }
}


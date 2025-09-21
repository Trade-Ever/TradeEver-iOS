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
    @Published var domesticCars: [String] = []
    @Published var importedCars: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCarManufacturers(category: String) async {
        isLoading = true
        defer { isLoading = false } // 함수가 종료될 때 반드시 실행되는 코드 블록
                
        do {
            let response = try await AF.request(APIEndpoint.manufacturers.url,
                                                method: .get,
                                                parameters: ["category": category],
                                                encoding: URLEncoding.default)
                .serializingDecodable(ApiResponse<[String]>.self)
                .value
            
            if response.success, let manufacturers = response.data {
                if category == "국산" {
                    domesticCars = manufacturers
                } else {
                    importedCars = manufacturers
                }
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

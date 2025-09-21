////
////  ManufacturerViewModel.swift
////  Trever
////
////  Created by OhChangEun on 9/21/25.
////
//

import Foundation
import SwiftUI
import Alamofire

@MainActor
class CarYearViewModel: ObservableObject {
    @Published var carYears: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCarYears(category: String, manufacturer: String, carName: String, modelName: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let parameters = [
            "category": category,
            "manufacturer": manufacturer,
            "carName": carName,
            "modelName": modelName
        ]
        
        do {
            let response = try await AF.request(APIEndpoint.years.url,
                                                method: .get,
                                                parameters: parameters,
                                                encoding: URLEncoding.default)
                .serializingDecodable(ApiResponse<[Int]>.self)
                .value
            
            if response.success, let years = response.data {
                carYears = years.map { "\($0)" }
            } else {
                errorMessage = response.message
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

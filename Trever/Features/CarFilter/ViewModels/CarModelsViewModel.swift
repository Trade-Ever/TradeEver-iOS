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
        isLoading = true
        defer { isLoading = false }
                
        do {
            let response = try await AF.request(APIEndpoint.modelNames.url,
                                                method: .get,
                                                parameters: [
                                                    "category": category,
                                                    "manufacturer": manufacturer,
                                                    "carName": carName
                                                ],
                                                encoding: URLEncoding.default)
                .serializingDecodable(ApiResponse<[String]>.self)
                .value
        
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

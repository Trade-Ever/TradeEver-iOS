//
//  CarYearViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/21/25.
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
        guard !isLoading else { return }   // 이미 실행 중이면 무시
        isLoading = true
        defer { isLoading = false }
        
        let parameters = [
            "category": category,
            "manufacturer": manufacturer,
            "carName": carName,
            "modelName": modelName
        ]
        
        do {
            let response: ApiResponse<[Int]> = try await NetworkManager.shared.request(
                to: .years,
                parameters: parameters,
                responseType: ApiResponse<[Int]>.self
            )
            
            if response.success, let years = response.data {
                carYears = years.map { "\($0)" } // Int → String 변환
            } else {
                errorMessage = response.message
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

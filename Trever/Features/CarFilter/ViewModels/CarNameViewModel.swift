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
    @Published var carNames: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func fetchCarNames(category: String, manufacturer: String) async {
        guard !isLoading else { return }   // 이미 실행 중이면 무시
        isLoading = true
        defer { isLoading = false } 
                
        do {
            let response: ApiResponse<[String]> = try await NetworkManager.shared.request(
                to: .carNames,
                parameters: [
                    "category": category,
                    "manufacturer": manufacturer
                ],
                responseType: ApiResponse<[String]>.self
            )
        
            if response.success, let names = response.data {
                carNames = names
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

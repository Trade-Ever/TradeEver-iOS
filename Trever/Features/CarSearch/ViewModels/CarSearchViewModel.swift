//
//  CarSearchViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import Foundation
import Combine

@MainActor
class CarSearchViewModel: ObservableObject {
    @Published var recentSearches: [String] = []
    @Published var searchText: String = ""
    
    @Published var vehicles: [Vehicle] = []
    @Published var totalCount: Int = 0
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 0
    @Published var isSearching: Bool = false
    
    @Published var errorMessage: String? = nil
    
    
    // 필터 조건으로 검색 API 호출
    func fetchFilteredCars(with carSearch: CarSearchModel) async {
        // CarSearch -> CarSearchRequest 변환
        let requestModel = transform(with: carSearch)
    }
    
    func resetFilters() {
        // 필터 리셋 로직
    }
    
    // 변환: CarSearch -> CarSearchRequest
    func transform(with carSearch: CarSearchModel) -> CarSearchRequest {
        return CarSearchRequest(
            keyword: carSearch.keyword,
            manufacturer: carSearch.manufacturer,
            carName: carSearch.carName,
            carModel: carSearch.carModel,
            yearStart: carSearch.yearStart,
            yearEnd: carSearch.yearEnd,
            mileageStart: carSearch.mileageStart,
            mileageEnd: carSearch.mileageEnd,
            priceStart: carSearch.priceStart,
            priceEnd: carSearch.priceEnd,
            vehicleType: carSearch.vehicleType,
            page: 1,
            size: 20
        )
    }
    
    // 최근 검색 기록 출력
    func fetchRecentSearches() async {
        do {
            let response: ApiResponse<[String]> = try await NetworkManager.shared.request(
                to: .recentSearch,
                responseType: ApiResponse<[String]>.self
            )
            
            if response.success, let searches = response.data {
                // 최대 5개까지만 표시
                recentSearches = Array(searches.prefix(5))
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // 최근 검색 기록 삭제
    func removeRecentSearch(_ keyword: String) async {
        do {
            let response: ApiResponse<String> = try await NetworkManager.shared.request(
                to: .deleteRecentSearch(keyword: keyword),
                method: .delete,
                responseType: ApiResponse<String>.self
            )
            
            if response.success {
                recentSearches.removeAll { $0 == keyword }
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}

//
//  MySellCarViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/24/25.
//

import SwiftUI
import Combine

@MainActor
class MySellCarViewModel: ObservableObject {
    @Published var myCars: [Vehicle] = []
    @Published var totalCount: Int = 0  // 전체 개수 저장

    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMoreData = true
    @Published var errorMessage: String?
    
    private var currentPage = 0
    private let pageSize = 10

    func fetchMyCars() async {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 0
        hasMoreData = true
        
        print("📤 [내 차량 요청] page: \(currentPage), size: \(pageSize)")
        
        do {
            let response: ApiResponse<VehicleResponse> = try await NetworkManager.shared.request(
                to: .myVehicles(currentPage: currentPage, pageSize: pageSize),
                responseType: ApiResponse<VehicleResponse>.self
            )
            
            print("[내 차량 응답] success=\(response.success), data count=\(response.data?.totalCount ?? 0)")
            
            if response.success, let cars = response.data {
                myCars = cars.vehicles
                totalCount = cars.totalCount  // 전체 개수 저장
                hasMoreData = cars.pageSize >= pageSize
                currentPage = 1
            } else {
                errorMessage = response.message
                myCars = []
                totalCount = 0
            }
        } catch {
            errorMessage = error.localizedDescription
            print("내 차량 네트워크 오류: \(error)")
            myCars = []
            totalCount = 0
        }
        
        isLoading = false
    }
    
    func loadMoreCars() async {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        print("[내 차량 추가 로드] page: \(currentPage), size: \(pageSize)")
        
        do {
            let response: ApiResponse<VehicleResponse> = try await NetworkManager.shared.request(
                to: .myVehicles(currentPage: currentPage, pageSize: pageSize),
                responseType: ApiResponse<VehicleResponse>.self
            )
            
            if response.success, let cars = response.data {
                myCars.append(contentsOf: cars.vehicles)
                totalCount = cars.totalCount // 추가 데이터 로드시에도 갱신
                hasMoreData = cars.pageSize >= pageSize
                currentPage += 1
            } else {
                hasMoreData = false
            }
        } catch {
            print("내 차량 추가 로드 오류: \(error)")
            hasMoreData = false
        }
        
        isLoadingMore = false
    }
    
    func refreshCars() async {
        await fetchMyCars()
    }
}

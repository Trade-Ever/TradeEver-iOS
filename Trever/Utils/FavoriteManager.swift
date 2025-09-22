//
//  FavoriteManager.swift
//  Trever
//
//  Created by Assistant on 9/21/25.
//

import Foundation
import SwiftUI

@MainActor
final class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    
    // vehicleId -> isFavorite 상태 저장
    @Published var favoriteStates: [Int: Bool] = [:]
    // vehicleId -> favoriteCount 저장
    @Published var favoriteCounts: [Int: Int] = [:]
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 특정 차량의 찜하기 상태 조회
    func isFavorite(vehicleId: Int) -> Bool {
        return favoriteStates[vehicleId] ?? false
    }
    
    /// 특정 차량의 찜하기 카운트 조회
    func favoriteCount(vehicleId: Int) -> Int? {
        return favoriteCounts[vehicleId]
    }
    
    /// 찜하기 상태 설정 (초기 데이터 로드 시 사용)
    func setFavoriteState(vehicleId: Int, isFavorite: Bool) {
        favoriteStates[vehicleId] = isFavorite
    }
    
    /// 찜하기 카운트 설정 (초기 데이터 로드 시 사용)
    func setFavoriteCount(vehicleId: Int, count: Int) {
        favoriteCounts[vehicleId] = count
    }
    
    /// 찜하기 토글 (API 호출 후 결과 반영)
    func toggleFavorite(vehicleId: Int, newState: Bool) {
        favoriteStates[vehicleId] = newState
        
        // 카운트도 함께 업데이트
        if let currentCount = favoriteCounts[vehicleId] {
            let newCount = newState ? currentCount + 1 : max(0, currentCount - 1)
            favoriteCounts[vehicleId] = newCount
        }
    }
    
    /// 찜하기 상태와 카운트를 함께 설정 (API 응답에서 받은 데이터)
    func updateFavoriteData(vehicleId: Int, isFavorite: Bool, count: Int) {
        favoriteStates[vehicleId] = isFavorite
        favoriteCounts[vehicleId] = count
    }
    
    /// 특정 차량의 찜하기 데이터 제거 (차량이 삭제된 경우)
    func removeFavoriteData(vehicleId: Int) {
        favoriteStates.removeValue(forKey: vehicleId)
        favoriteCounts.removeValue(forKey: vehicleId)
    }
    
    /// 모든 찜하기 데이터 초기화
    func clearAllData() {
        favoriteStates.removeAll()
        favoriteCounts.removeAll()
    }
    
    // MARK: - Debug Methods
    
    func printAllStates() {
        print("🔍 FavoriteManager 상태:")
        print("   - Favorite States: \(favoriteStates)")
        print("   - Favorite Counts: \(favoriteCounts)")
    }
}

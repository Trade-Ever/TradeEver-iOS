//
//  CarSearchViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import Foundation
import Combine

class CarSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var recentSearches: [RecentSearch] = [
        RecentSearch(term: "GV80"),
        RecentSearch(term: "GV80"),
        RecentSearch(term: "GV80"),
        RecentSearch(term: "GV80")
    ]
    @Published var filters = CarSearchFilter()
    
    func addRecentSearch(_ term: String) {
        guard !term.isEmpty else { return }
        let newSearch = RecentSearch(term: term)
        recentSearches.insert(newSearch, at: 0)
        if recentSearches.count > 10 {
            recentSearches.removeLast()
        }
    }
    
    func removeRecentSearch(_ search: RecentSearch) {
        recentSearches.removeAll { $0.id == search.id }
    }
    
    func clearAllRecentSearches() {
        recentSearches.removeAll()
    }
    
    func performSearch() {
        addRecentSearch(searchText)
        // 실제 검색 로직 구현
        print("검색 실행: \(searchText)")
        print("필터: \(filters)")
    }
    
    func resetFilters() {
        filters = CarSearchFilter()
    }
}

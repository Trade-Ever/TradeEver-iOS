//
//  RecentSearchView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct RecentSearchView: View {
    let recentSearches: [String]
    let onSearchTap: (String) -> Void
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if recentSearches.isEmpty {
                // 검색어가 없는 경우
                Text("최근 검색어가 없습니다")
                    .font(.system(size: 16))
                    .foregroundColor(.purple300)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                Spacer()
            } else {
                // 검색어가 있는 경우
                Text("최근 검색")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.grey300.opacity(0.5))
                    .padding(.horizontal, 28)
                    .padding(.top, 8)
                
                // 최근 검색 리스트
                ForEach(Array(recentSearches.prefix(5).enumerated()), id: \.offset) { index, searchTerm in
                    HStack {
                        Button(action: { onSearchTap(searchTerm) }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.grey300.opacity(0.8))
                                    .font(.system(size: 16))
                                
                                Text(searchTerm)
                                    .font(.system(size: 16))
                                    .foregroundColor(.grey400)
                                    .padding(.leading, 4)

                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            onRemove(searchTerm)
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.grey300.opacity(0.5))
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 13)
                    .padding(.bottom, 12)
                    
                    if index != recentSearches.prefix(5).count - 1 {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: 320) // 항상 280pt 공간 유지
    }
}

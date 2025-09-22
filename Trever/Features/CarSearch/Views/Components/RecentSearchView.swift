//
//  RecentSearchView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct RecentSearchView: View {
    let recentSearches: [RecentSearch]
    let onSearchTap: (String) -> Void
    let onRemove: (RecentSearch) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("최근 검색")
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            ForEach(recentSearches, id: \.id) { search in
                HStack {
                    Button(action: {
                        onSearchTap(search.term)
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            Text(search.term)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        onRemove(search)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                if search.id != recentSearches.last?.id {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

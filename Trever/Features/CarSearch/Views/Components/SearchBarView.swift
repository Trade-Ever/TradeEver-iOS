//
//  SearchBarView.swift
//  Trever
//
//  Created by OhChangEun on 9/22/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    let onClose: (() -> Void)?
    @FocusState private var isFocused: Bool
    
    init(searchText: Binding<String>, onClose: (() -> Void)? = nil) {
        self._searchText = searchText
        self.onClose = onClose
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 검색 입력 박스
            HStack(spacing: 10) {
                // 돋보기 아이콘
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.grey300)
                    .font(.body)
                
                // 커스텀 텍스트 입력 영역
                TextField("차량 검색", text: $searchText)
                    .foregroundStyle(searchText.isEmpty ? Color.grey400.opacity(0.7) : Color.black)
                    .font(.body)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        // 검색 실행
                        performSearch()
                    }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white)
                    .shadow(
                        color: Color.black.opacity(0.12),
                        radius: 4,
                        x: 0,
                        y: 1
                    )
            )
            .onTapGesture {
                isFocused = true
            }
            
            // 취소 버튼 (검색창 바깥, onClose가 있을 때만)
            if let onClose = onClose {
                Button("취소") {
                    onClose()
                }
                .foregroundColor(.purple400)
                .font(.body)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
    
    private func performSearch() {
        // 검색 로직 (필요시 구현)
        isFocused = false
        print("검색: \(searchText)")
    }
}

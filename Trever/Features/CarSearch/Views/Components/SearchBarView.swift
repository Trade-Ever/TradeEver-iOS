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
                    .foregroundColor(iconColor)
                    .font(.body)
                
                // 커스텀 텍스트 입력 영역
                TextField("차량 검색", text: $searchText)
                    .foregroundColor(textColor)
                    .font(.body)
                    .focused($isFocused)
                
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(borderColor, lineWidth: 1.5)
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
    
    // MARK: - 색상 상태
    private var iconColor: Color {
        isFocused || !searchText.isEmpty ? .purple400 : .gray.opacity(0.6)
    }
    
    private var textColor: Color {
        isFocused || !searchText.isEmpty ? .purple400 : .gray.opacity(0.6)
    }
    
    private var borderColor: Color {
        isFocused || !searchText.isEmpty ? .purple300 : Color.clear
    }
}

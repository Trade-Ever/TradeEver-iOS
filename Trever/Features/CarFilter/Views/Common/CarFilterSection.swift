//
//  ManufacturerSection.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

// 섹션 컴포넌트
struct CarFilterSection: View {
    let title: String                           // 작은 제목
    let data: [(String?, String, Int, Bool)]    // 제조사 목록
    let showDivider: Bool                       // 구분선
    let onRowTap: (String) -> Void              // 클릭 시 호출

    // 기본값 init
    init(title: String = "",
         data: [(String?, String, Int, Bool)],
         showDivider: Bool = false,
         onRowTap: @escaping (String) -> Void = { _ in }) {
        self.title = title
        self.data = data
        self.showDivider = showDivider
        self.onRowTap = onRowTap
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 작은 제목
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.grey300.opacity(0.6))
                    .padding(.leading)
            }
            
            // 제조사 리스트
            ForEach(data, id: \.1) { data in
                CarFilterRow(
                    image: data.0 ?? "",
                    name: data.1,
                    count: data.2,
                    isSelected: data.3,
                    onTap: {
                        onRowTap(data.1)
                    }
                )
            }
            
            // 구분선 표시
            if showDivider {
                Divider()
                    .frame(height: 0.5) // 높이 조절 가능
                    .background(Color.grey50)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
        }
        .padding(.top, 12)
    }
}

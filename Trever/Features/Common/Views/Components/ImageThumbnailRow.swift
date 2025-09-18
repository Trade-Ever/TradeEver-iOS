//
//  ImageThumbnailRow.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

struct ImageThumbnailRow: View {
    @Binding var imagesData: [Data] // 선택된 이미지 배열
    let maxCount: Int = 5  // 최대 표시할 이미지 수
    
    var body: some View {
        if !imagesData.isEmpty {
            HStack(spacing: 8) {
                ForEach(imagesData.prefix(maxCount).indices, id: \.self) { index in
                    if let uiImage = UIImage(data: imagesData[index]) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .shadow(radius: 2)
                            
                            Button(action: {
                                imagesData.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.white)
                                    .background(Color.grey300.opacity(0.2).clipShape(Circle()))
                            }
                            .offset(x: -2, y: 2) // 버튼을 이미지 안쪽으로 이동
                            .zIndex(1)           // 버튼을 항상 위로 올림
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
    }
}

//
//  VehicleNamePage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI
import PhotosUI

struct ImageUploadView: View {
    @State private var vehicleColor: String = ""
    @State private var step: Int = 0
    
    // 업로드 이미지 저장용
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    enum Field: Hashable {
        case color
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 24) {
            
            // 1. 이미지 업로드
            if step >= 0 {
                InputSection(title: "실물 이미지를 업로드해주세요") {
                    VStack {
                        if let data = selectedImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("이미지 선택")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .onChange(of: selectedItem) { oldItem, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    withAnimation(.easeInOut) {
                                        step = 1
                                        focusedField = .color
                                    }
                                }
                            }
                        }
                    }
                }
                .stepTransition(step: step, target: 0)
            }
            
            // 2. 색상 입력
            if step >= 1 {
                InputSection(title: "색상을 입력해주세요") {
                    CustomInputBox(
                        placeholder: "흰색",
                        text: $vehicleColor
                    )
                    .focused($focusedField, equals: .color)
                    .onSubmit {
                        focusedField = nil
                    }
                }
                .stepTransition(step: step, target: 1)
            }
        }
    }
}

#Preview {
    ImageUploadView()
}


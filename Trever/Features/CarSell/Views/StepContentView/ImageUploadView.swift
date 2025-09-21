//
//  VehicleNamePage.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI
import PhotosUI

struct ImageUploadView: View {
    @Binding var vehicleColor: String
    @Binding var selectedImagesData: [Data]
    
    @Binding var step: Int
    @State private var selectedItem: PhotosPickerItem? = nil
    
    enum Field: Hashable {
        case image, color
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 12) {
            // 1. 이미지 업로드
            if step >= 0 {
                InputSection(title: "실물 이미지를 업로드해주세요") {
                    HStack {
                        Spacer()
                        ImageUploader(selectedImagesData: $selectedImagesData) {
                            // 메인 스레드에서 1초 후 동작하도록(색상 입력란 썸네일 등장 후 등장하도록)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation {
                                    step = max(step, 1)
                                    focusedField = .color
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // 이미지 썸네일
                    ImageThumbnailRow(imagesData: $selectedImagesData)
                        .padding(.bottom, 26)
                }
                .stepTransition(step: step, target: 0)
            }
            
            // 3. 색상 입력
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

struct ImageUploadView_Previews: PreviewProvider {
    @State static var vehicleColor = ""
    @State static var selectedImagesData: [Data] = []
    @State static var step = 0

    static var previews: some View {
        ImageUploadView(
            vehicleColor: $vehicleColor,
            selectedImagesData: $selectedImagesData,
            step: $step
        )
        .previewLayout(.sizeThatFits)
    }
}


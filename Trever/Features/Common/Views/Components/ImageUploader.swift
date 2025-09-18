//
//  ImageUploader.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//
import SwiftUI
import PhotosUI

struct ImageUploader: View {
    @Binding var selectedImagesData: [Data] // 최대 5장 저장
    var onImageSelected: (() -> Void)? = nil
    
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundColor(Color.purple300)
                    .frame(width: 280, height: 180)

                VStack {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 32))
                            .foregroundColor(Color.purple300)
                        Text("사진 선택(최대 5장)")
                            .font(.system(size: 16))
                            .foregroundColor(Color.purple300.opacity(0.8))
                            .padding(.top, 4)
                    }
                    .padding(4)

                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 5,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("이미지 선택")
                            .frame(maxWidth: .infinity)
                            .frame(width: 148, height: 44)
                            .background(Color.purple300)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .onChange(of: selectedItems) { oldItems, newItems in
                        Task {
                            var tempData: [Data] = []
                            for item in newItems.prefix(5) {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    tempData.append(data)
                                }
                            }
                            selectedImagesData = tempData
                            onImageSelected?() // 선택 완료 시 부모에게 알림
                        }
                    }
                }
            }
        }
    }
}

struct ImageUploader_Previews: PreviewProvider {
    @State static var imagesData: [Data] = []

    static var previews: some View {
        ImageUploader(selectedImagesData: $imagesData)
            .padding()
    }
}

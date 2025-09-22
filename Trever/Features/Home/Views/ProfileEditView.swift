//
//  ProfileEditView.swift
//  Trever
//
//  Created by 채상윤 on 9/22/25.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    let userProfile: UserProfileData?
    let onSave: (String, String, String, String, Data?) async -> Void
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var locationCity: String = ""
    @State private var birthDate: Date = Date()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isSubmitting = false
    @State private var showingDatePicker = false
    @State private var tempBirthDate = Date()
    
    @Environment(\.dismiss) private var dismiss
    
    private let brand = Color(red: 101/255, green: 40/255, blue: 247/255)
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !phone.isEmpty && !locationCity.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 프로필 이미지
                VStack(spacing: 16) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let profileImageUrl = userProfile?.profileImageUrl, !profileImageUrl.isEmpty {
                            AsyncImage(url: URL(string: profileImageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(Color.grey100)
                                    .overlay(Image(systemName: "person").foregroundStyle(.secondary))
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.grey100)
                                .frame(width: 100, height: 100)
                                .overlay(Image(systemName: "person").foregroundStyle(.secondary))
                        }
                    }
                    
                    Text("프로필 사진 변경")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                // 입력 폼
                ScrollView {
                    VStack(spacing: 20) {
                        // 이름 입력
                        InputSection(title: "이름") {
                            CustomInputBox(
                                placeholder: "이름을 입력하세요",
                                text: $name
                            )
                        }
                        
                        // 전화번호 입력
                        InputSection(title: "전화번호") {
                            CustomInputBox(
                                inputType: .number,
                                placeholder: "010-0000-0000",
                                text: $phone
                            )
                        }
                        
                        // 생년월일 입력
                        InputSection(title: "생년월일") {
                            CustomInputBox(
                                placeholder: dateFormatter.string(from: birthDate),
                                showSheet: true,
                                textColor: .black,
                                text: .constant("")
                            )
                            .onTapGesture {
                                tempBirthDate = birthDate
                                showingDatePicker = true
                            }
                        }
                        
                        // 지역 입력
                        InputSection(title: "지역") {
                            CustomInputBox(
                                placeholder: "지역을 입력하세요",
                                text: $locationCity
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // 저장 버튼
                Button(action: {
                    saveProfile()
                }) {
                    Text("저장")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? brand : Color.gray)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .disabled(!isFormValid || isSubmitting)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("프로필 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadInitialData()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingDatePicker) {
            VStack(spacing: 0) {
                DatePicker("생년월일", selection: $tempBirthDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    birthDate = tempBirthDate
                    showingDatePicker = false
                }) {
                    Text("선택")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brand)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .presentationDetents([.medium])
        }
        .overlay(
            Group {
                if isSubmitting {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("저장 중...")
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                }
            }
        )
    }
    
    private func loadInitialData() {
        if let profile = userProfile {
            name = profile.name
            phone = profile.phone
            locationCity = profile.locationCity
            
            // 생년월일 파싱
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: profile.birthDate) {
                birthDate = date
                tempBirthDate = date
            }
        }
    }
    
    private func saveProfile() {
        isSubmitting = true
        
        Task {
            let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            await onSave(
                name,
                phone,
                locationCity,
                dateFormatter.string(from: birthDate),
                imageData
            )
            
            await MainActor.run {
                isSubmitting = false
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileEditView(
        userProfile: nil,
        onSave: { _, _, _, _, _ in }
    )
}

//
//  SignupViewModel.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import Foundation

//@MainActor
//final class SignUpViewModel: ObservableObject {
//    @Published var model = SignUpModel()
//    
//    // 상태
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var successResponse: UserSignUpResponse?
//    
//    func signUp() async {
//        guard model.password == model.checkedPassword else {
//            errorMessage = "비밀번호가 일치하지 않습니다."
//            return
//        }
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        
//        let request = UserSignUpRequest(
//            email: model.email,
//            password: model.password,
//            checkedPassword: model.checkedPassword,
//            name: model.name,
//            phone: model.phone,
//            birthDate: formatter.string(from: model.birthDate),
//            profileImageUrl: model.profileImageUrl,
//            locationCity: model.locationCity
//        )
//        
//        do {
//            isLoading = true
//            let response: UserSignUpResponse = try await AFNetworkManager.shared.request(
//                url: "https://api.example.com/signup",
//                method: .post,
//                parameters: request
//            )
//            successResponse = response
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        isLoading = false
//    }
//}

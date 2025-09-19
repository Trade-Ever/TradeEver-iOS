//
//  LoginView.swift
//  Trever
//
//  Created by OhChangEun on 9/18/25.
//

import SwiftUI

/***
 "email": "string",
 "password": "1234"‚
 "checkedPassword": "string",
 "name":"string",
 
 "phone": "014503-0118",
 "birthDate": "2025-09-18",
 "profileImageUrl": "string",
 "locationCity": "string"
 */

struct SignupView: View {
    @State private var currentStep: Int = 0

    @StateObject private var viewModel = SignupModel()
    @StateObject private var keyboard = KeyboardState()

    @FocusState private var focusedField: Field?
    
    let totalSteps: Int = 2

    enum Field: Hashable {
        case email, password, checkedPassword, name, phone, profileImageUrl, locationCity
    }
    
    var body: some View {
        VStack {
            ScrollView {
                if currentStep == 0 {
                    SignupPage1(
                        email: $viewModel.email,
                        password: $viewModel.password,
                        checkedPassword: $viewModel.checkedPassword,
                        focusedField: _focusedField
                    )
                } else if currentStep == 1 {
                    SignupPage2(
                        name: $viewModel.name,
                        phone: $viewModel.phone,
                        profileImageUrl: $viewModel.profileImageUrl,
                        locationCity: $viewModel.locationCity,
                        birthDate: $viewModel.birthDate,
                        focusedField: _focusedField
                    )
                }
            }
        }
        .onAppear { focusedField = .email }
        // 키보드가 있을 때, 입력 필드를 조금 더 띄우기 위한 추가 여백
        .safeAreaInset(edge: .bottom) {
            StepActionBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                onNext: { currentStep = min(currentStep + 1, totalSteps - 1) },
                onPrevious: { currentStep = max(currentStep - 1, 0) },
                isStepCompleted: { viewModel.isStepCompleted(currentStep: $0) }
            )
        }
    }
}


struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .previewLayout(.sizeThatFits)
    }
}

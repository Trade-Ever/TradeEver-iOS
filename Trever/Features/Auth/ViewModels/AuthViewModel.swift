//
//  AuthViewModel.swift
//  Trever
//
//  Created by 채상윤 on 9/21/25.
//

import Foundation
import GoogleSignIn
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var isSignedIn = false
    @Published var user: GIDGoogleUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var idToken: String?
    @Published var profileComplete = false
    @Published var isNewLogin = false // 새로 로그인한 경우인지 구분
    
    private init() {
        // 현재 로그인 상태 확인
        checkAuthState()
    }
    
    func checkAuthState() {
        // TokenManager에서 로그인 상태 확인
        if TokenManager.shared.isLoggedIn {
            print("AccessToken:  \(TokenManager.shared.accessToken ?? "없음")")
            print("자동 로그인 - 토큰 유효성 검증 중...")
            
            // 토큰 유효성 검증을 위해 API 호출
            Task {
                await validateToken()
            }
        } else if let user = GIDSignIn.sharedInstance.currentUser {
            print("Google 로그인")
            print("Google 사용자 이메일: \(user.profile?.email ?? "없음")")
            print("Google 사용자 이름: \(user.profile?.name ?? "없음")")
            print("Google 사용자 ID: \(user.userID ?? "없음")")
            
            self.user = user
            self.idToken = user.idToken?.tokenString
        } else {
            print("로그인된 사용자 없음")
            self.isSignedIn = false
            self.user = nil
            self.idToken = nil
            self.profileComplete = false
            self.isNewLogin = false
        }
    }
    
    func signInWithGoogle() async {
        // 기존 토큰 완전 삭제 (다른 계정 로그인 시 충돌 방지)
        print("기존 토큰 삭제 중...")
        TokenManager.shared.clearTokens()
        GIDSignIn.sharedInstance.signOut()
        
        // GoogleService-Info.plist에서 clientID 가져오기
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            print("GoogleService-Info.plist 파일을 찾을 수 없거나 CLIENT_ID가 없습니다")
            errorMessage = "Google 설정을 확인해주세요."
            return
        }
        
        print("Google clientID 확인됨: \(clientID)")
        print("Client ID 상세 정보: \(clientID)")
        
        // GoogleSignIn 설정
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("Google Sign-In 설정 완료")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("화면을 찾을 수 없습니다")
            errorMessage = "화면을 찾을 수 없습니다."
            return
        }
        
        do {
            isLoading = true
            errorMessage = nil
            print("Google Sign-In 요청 중...")
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = result.user
            print("Google Sign-In 성공")
            print("사용자 이메일: \(user.profile?.email ?? "없음")")
            print("사용자 이름: \(user.profile?.name ?? "없음")")
            print("사용자 ID: \(user.userID ?? "없음")")
            
            guard let idToken = user.idToken?.tokenString else {
                print("ID 토큰을 가져올 수 없습니다")
                errorMessage = "ID 토큰을 가져올 수 없습니다."
                return
            }
            
            print("ID Token: \(idToken)")
            
            // Firebase Auth 대신 Google 사용자 정보만 저장
            self.user = user
            self.isSignedIn = true
            self.idToken = idToken
            print("로그인 상태 업데이트 완료")
            print("Google 로그인 완료! 백엔드로 ID Token 전송 가능")
            
            // 백엔드로 ID Token 전송
            await authenticateWithBackend()
            
        } catch {
            print("Google 로그인 실패: \(error.localizedDescription)")
            print("에러 타입: \(type(of: error))")
            errorMessage = "Google 로그인 실패: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // 토큰 유효성 검증
    func validateToken() async {
        print("토큰 유효성 검증 시작")
        
        let isValid = await NetworkManager.shared.validateToken()
        
        if isValid {
            print("토큰 유효 - 자동 로그인 성공")
            self.isSignedIn = true
            self.isNewLogin = false
            
            // 자동 로그인 시에는 로컬에 저장된 profileComplete 값 사용
            self.profileComplete = TokenManager.shared.profileComplete
            print("   - Profile Complete (로컬): \(self.profileComplete)")
        } else {
            print("토큰 재발급도 실패 - 로그아웃 처리")
            // 토큰 재발급도 실패했으므로 로그아웃 처리
            await signOut()
        }
    }
    
    // 백엔드로 ID Token 전송하여 인증
    func authenticateWithBackend() async {
        guard let idToken = self.idToken else {
            print("ID Token이 없습니다")
            errorMessage = "ID Token이 없습니다."
            return
        }
        
        print("백엔드로 Google 로그인 API 호출 중...")
        print("전송할 ID Token: \(idToken)")
        
        guard let response = await NetworkManager.shared.authenticateWithGoogle(idToken: idToken) else {
            print("백엔드 인증 실패: API 호출 실패")
            errorMessage = "서버 연결에 실패했습니다."
            return
        }
        
        if response.success, let data = response.data {
            print("백엔드 인증 성공!")
            
            // 토큰 저장
            TokenManager.shared.saveTokens(
                accessToken: data.accessToken,
                refreshToken: data.refreshToken,
                profileComplete: data.profileComplete
            )
            
            // 상태 업데이트
            self.isSignedIn = true
            self.profileComplete = data.profileComplete
            self.isNewLogin = true // 새로 로그인
            
            print("새로 로그인 완료!")
            print("   - isSignedIn: \(self.isSignedIn)")
            print("   - Profile Complete: \(data.profileComplete)")
            print("   - isNewLogin: \(self.isNewLogin)")
            
        } else {
            print("백엔드 인증 실패: \(response.message)")
            errorMessage = response.message
        }
    }
    
    // 로그아웃
    func signOut() async {
        print("로그아웃 시작")
        
        // 서버에 로그아웃 API 호출
        let serverLogoutSuccess = await NetworkManager.shared.logout()
        
        if serverLogoutSuccess {
            print("서버 로그아웃 성공")
        } else {
            print("서버 로그아웃 실패 (로컬 로그아웃은 진행)")
        }
        
        // Google Sign-In 로그아웃
        GIDSignIn.sharedInstance.signOut()
        
        // 토큰 삭제
        TokenManager.shared.clearTokens()
        
        // 상태 초기화
        self.isSignedIn = false
        self.user = nil
        self.idToken = nil
        self.profileComplete = false
        
        print("로그아웃 완료")
        print("   - isSignedIn: \(self.isSignedIn)")
        print("   - 화면이 로그인 화면으로 변경되어야 함")
    }
    
    // 프로필 완성
    func completeProfile(name: String, phone: String, birthDate: String, locationCity: String) async -> Bool {
        print("프로필 완성 시작")
        print("   - 이름: \(name)")
        print("   - 전화번호: \(phone)")
        print("   - 생년월일: \(birthDate)")
        print("   - 지역: \(locationCity)")
        
        let success = await NetworkManager.shared.completeProfile(
            name: name,
            phone: phone,
            birthDate: birthDate,
            locationCity: locationCity
        )
        
        if success {
            print("프로필 완성 성공")
            
            // 프로필 완성 상태 업데이트
            self.profileComplete = true
            self.isNewLogin = false // 새로 로그인 상태 해제
            TokenManager.shared.profileComplete = true
            
            print("   - profileComplete: \(self.profileComplete)")
            print("   - isNewLogin: \(self.isNewLogin)")
            print("   - 메인 화면으로 이동")
        } else {
            print("프로필 완성 실패")
            errorMessage = "프로필 정보 저장에 실패했습니다."
        }
        
        return success
    }
}

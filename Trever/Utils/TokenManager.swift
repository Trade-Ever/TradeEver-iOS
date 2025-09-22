//
//  TokenManager.swift
//  Trever
//
//  Created by 채상윤 on 9/22/25.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let profileCompleteKey = "profile_complete"
    
    private init() {}
    
    // MARK: - Access Token
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: accessTokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: accessTokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: accessTokenKey)
            }
        }
    }
    
    // MARK: - Refresh Token
    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: refreshTokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: refreshTokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: refreshTokenKey)
            }
        }
    }
    
    // MARK: - Profile Complete
    var profileComplete: Bool {
        get {
            return UserDefaults.standard.bool(forKey: profileCompleteKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: profileCompleteKey)
        }
    }
    
    // MARK: - Token Management
    func saveTokens(accessToken: String, refreshToken: String, profileComplete: Bool) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.profileComplete = profileComplete
        print("✅ 토큰 저장 완료")
        print("   - Access Token: \(accessToken.prefix(20))...")
        print("   - Refresh Token: \(refreshToken.prefix(20))...")
        print("   - Profile Complete: \(profileComplete)")
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        profileComplete = false
        print("🗑️ 토큰 삭제 완료")
    }
    
    var isLoggedIn: Bool {
        return accessToken != nil
    }
    
    // MARK: - Authentication Header
    var authorizationHeader: [String: String] {
        guard let token = accessToken else {
            return [:]
        }
        return ["Authorization": "Bearer \(token)"]
    }
}

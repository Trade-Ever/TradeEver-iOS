//
//  Color.swift
//  Trever
//
//  Created by Admin on 9/15/25.
//

import Foundation
import SwiftUI

extension Color {
    
    // MARK: - Brand Colors (다크모드에서도 동일)
    static let purple700 = Color(hex: "#2B1073")
    static let purple600 = Color(hex: "#39189A") 
    static let purple500 = Color(hex: "#4B1ECF")
    static let purple400 = Color(hex: "#6528F7") // main
    static let purple300 = Color(hex: "#A076F9")
    static let purple200 = Color(hex: "#D7BBF5")
    static let purple100 = Color(hex: "#EDE4FF")
    static let purple50  = Color(hex: "#F7F3FF")

    // MARK: - Status Colors (다크모드에서도 동일)
    static let likeRed   = Color(hex: "#EA3323")
    static let errorRed  = Color(hex: "#FF6C6C")
    static let priceGreen = Color(hex: "#00C364")
    
    // MARK: - Adaptive Colors (다크모드 지원)
    static let grey400 = Color.primary.opacity(0.8)
    static let grey300 = Color.primary.opacity(0.6)
    static let grey200 = Color.primary.opacity(0.4)
    static let grey100 = Color.primary.opacity(0.2)
    static let grey50  = Color.primary.opacity(0.1)
    
    // MARK: - Background Colors
//    static let cardBackground = Color(.systemBackground);l
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    
    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(.tertiaryLabel)
    
    // MARK: - Legacy Colors (호환성을 위해 유지)
    static let pureWhite = Color.white
    static let boxBgWhite = Color.white.opacity(0.25)
}

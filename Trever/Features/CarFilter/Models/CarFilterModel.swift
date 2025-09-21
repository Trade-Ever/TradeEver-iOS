//
//  CarFilterModel.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

class CarFilterModel: ObservableObject {
    @Published var category: String? = nil       // 국산 | 수입
    @Published var manufacturer: String? = nil   // 제조사
    @Published var carName: String? = nil        // 차명
    @Published var modelName: String? = nil      // 모델명
    @Published var carYear: String? = nil        // 연식
}


//
//  CarFilterModel.swift
//  Trever
//
//  Created by OhChangEun on 9/20/25.
//

import SwiftUI

class CarFilterModel: ObservableObject {
    @Published var manufacturer: String? = nil
    @Published var modelName: String? = nil
    @Published var carName: String? = nil
    @Published var carYear: String? = nil 
}


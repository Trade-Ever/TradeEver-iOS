//
//  StepBarView.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct StepBarView: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        
        HStack {
            Spacer(minLength: 52)
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step == currentStep ? Color.purple400 : Color.grey200)
                        .frame(height: 8)
                        .cornerRadius(20)
                }
            }
            Spacer(minLength: 52)

        }

        .padding(.horizontal)
    }
}

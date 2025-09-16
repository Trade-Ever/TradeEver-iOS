//
//  SellCarView.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct SellCarView: View {
    @State private var currentStep: Int = 0
    
    let totalSteps = 7
    
    var body: some View {
        NavigationStack {
            VStack {
                // Step Bar
                StepBarView(currentStep: $currentStep, totalSteps: totalSteps)
                    .padding(.top, 40)
                
                Spacer()
                
                // 현재 페이지 내용
                Group {
                    switch currentStep {
                        case 0: VehicleNumberPage()
                        case 1: VehicleInfoPage()
                        case 2: EngineInfoPage()
                        case 3: ImageUploadPage()
                        case 4: VehicleOptionPage()
                        case 5: AccidentInfoPage()
                        case 6: TradeInfoPage()
                        default: Text("Unknown Page")
                    }
                }
                .animation(.easeInOut, value: currentStep)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 40)
                
                Spacer()
                
                // 다음 버튼
                StepButton(currentStep: $currentStep, totalSteps: totalSteps, userInput: .constant(""))
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            .navigationTitle("") // 타이틀 숨기기
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep > 0 {
                        Button(action: {
                            currentStep -= 1
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("뒤로")
                            }
                            .foregroundColor(.purple400)
                        }
                    } else {
                        // 첫 페이지에는 보이지 않지만 공간을 차지하는 빈 뷰
                        Color.clear.frame(width: 60, height: 44)
                    }
                }
            }
        }
    }
}

struct SellCarView_Previews: PreviewProvider {
    static var previews: some View {
        SellCarView()
    }
}

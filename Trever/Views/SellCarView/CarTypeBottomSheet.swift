//
//  CarTypePickerSheet.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct CarTypeBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedCarTypes: [String]
    
    let carTypes = ["대형", "준중형", "중형", "소형", "스포츠", "SUV", "승합차", "경차"]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("차종 선택")
                .font(.title)
                .bold()
                .padding(.top, 24)
                .padding(.bottom, 12)
            
            // 2행 4열 버튼
            let rows = [Array(carTypes[0...3]), Array(carTypes[4...7])]
            
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { type in
                        Button(action: {
                            if selectedCarTypes.contains(type) {
                                selectedCarTypes.removeAll { $0 == type }
                            } else {
                                selectedCarTypes.append(type)
                            }
                        }) {
                            Text(type)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedCarTypes.contains(type) ? Color.purple300 : .white)
                                .foregroundColor(selectedCarTypes.contains(type) ?
                                    .white : .grey200)
                                .font(.system(size: 16))
                                .fontWeight(.black)
                                .cornerRadius(50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color.grey200, lineWidth: selectedCarTypes.contains(type) ? 0 : 1.5)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            
            Spacer()
            
            // 하단 버튼 교체
            BottomSheetButtons(
                onConfirm: {
                    isPresented = false
                },
                onReset: {
                    selectedCarTypes.removeAll()
                }
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// Preview
struct CarTypePickerSheet_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    @State static var selectedCarTypes: [String] = ["대형", "SUV"]
    
    static var previews: some View {
        CarTypeBottomSheet(isPresented: $isPresented, selectedCarTypes: $selectedCarTypes)
    }
}

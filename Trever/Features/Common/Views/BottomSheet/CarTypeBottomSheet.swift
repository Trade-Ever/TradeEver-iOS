//
//  CarTypePickerSheet.swift
//  Trever
//
//  Created by OhChangEun on 9/16/25.
//

import SwiftUI

struct CarTypeBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedCarType: String?  // 단일 선택으로 변경
    let action: () -> Void?

    let carTypes = ["대형", "준중형", "중형", "소형", "스포츠", "SUV", "승합차", "경차"]
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.grey200)
                .frame(width: 36, height: 5)
                .padding(.top, 20)
            
            Text("차종 선택")
                .font(.title2)
                .bold()
                .padding(.top, 24)
                .foregroundColor(.grey400)
            
            // 2행 4열 버튼
            let rows = [Array(carTypes[0...3]), Array(carTypes[4...7])]
            
            Spacer()

            ForEach(rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { type in
                        SelectableButton(
                            title: type,
                            isSelected: selectedCarType == type, // 단일 선택 비교
                            action: {
                                // 선택한 항목이 이미 선택된 경우 해제, 아니면 선택
                                if selectedCarType == type {
                                    selectedCarType = nil
                                } else {
                                    selectedCarType = type
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 4)
            }
            
            Spacer(minLength: 28) // 버튼과 하단 버튼 사이 여백

            // 하단 버튼 교체
            BottomSheetButtons(
                onConfirm: {
                    action()
                    isPresented = false
                },
                onReset: {
                    selectedCarType = nil
                }
            )
        }
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// Preview
struct CarTypePickerSheet_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    @State static var selectedCarType: String? = "대형"  // 단일 선택

    static var previews: some View {
        CarTypeBottomSheet(isPresented: $isPresented, selectedCarType: $selectedCarType, action: {})
    }
}

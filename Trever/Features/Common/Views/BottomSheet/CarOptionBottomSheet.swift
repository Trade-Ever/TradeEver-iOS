//
//  CarOptionBottomSheet.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

struct CarOptionBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedCarOptions: [String]
    
    let options = ["열선시트", "통풍시트", "썬루프", "열선핸들", "내비게이션", "전동시트", "어라운드뷰", "전동트렁크"]
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.grey200)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
            
            Text("차량 옵션 선택")
                .font(.title2)
                .bold()
                .padding(.top, 24)
                .foregroundColor(.grey400)

            // 2행 4열 버튼
            let rows = [Array(options[0...3]), Array(options[4...7])]
            
            Spacer()

            ForEach(rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { option in
                        SelectableButton(
                            title: option,
                            isSelected: selectedCarOptions.contains(option),
                            action: {
                                if selectedCarOptions.contains(option) {
                                    selectedCarOptions.removeAll { $0 == option }
                                } else {
                                    selectedCarOptions.append(option)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 4)
            }
            
            Spacer(minLength: 28) // 버튼과 하단 버튼 사이 여백

            BottomSheetButtons(
                onConfirm: {
                    isPresented = false
                },
                onReset: {
                    selectedCarOptions.removeAll()
                }
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// Preview
struct CarOptionPickerSheet_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    @State static var selectedOptions: [String] = ["썬루프", "내비게이션"]
    
    static var previews: some View {
        CarOptionBottomSheet(isPresented: $isPresented, selectedCarOptions: $selectedOptions)
    }
}

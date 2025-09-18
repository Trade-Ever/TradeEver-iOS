//
//  DatePickerButton.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

struct DatePickerButton: View {
    var title: String
    @Binding var date: Date?
    
    // 날짜 선택 제한
    var allowFutureDates: Bool = true   // true면 오늘부터 이후, false면 오늘 이전
    var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        if allowFutureDates {
            return today...Date.distantFuture
        } else {
            return Date.distantPast...today
        }
    }
    
    var onDateSelected: ((Date) -> Void)? = nil
    
    @State private var showPicker = false
    @State private var tempDate: Date = Date() // 시트 안에서 임시 저장
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df
    }()
    
    private func completeDateSelection() {
        date = tempDate
        onDateSelected?(tempDate)
        showPicker = false
    }
    
    var body: some View {
        Button(action: {
            // 시트 열 때 기존 날짜가 있으면 임시값에 넣기
            tempDate = date ?? Date()
            showPicker.toggle()
        }) {
            HStack {
                Text(date != nil ? dateFormatter.string(from: date!) : title)
                    .foregroundColor(date == nil ? Color.grey300.opacity(0.6) : .primary)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(date != nil ? .purple300 : .grey300.opacity(0.8))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(date != nil ? Color.purple300 : Color.grey200, lineWidth: 1)
            )        }
        .sheet(isPresented: $showPicker) {
            VStack {
                DatePicker(
                    title,
                    selection: $tempDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .tint(Color.purple300)
                
                Spacer()
                PrimaryButton(title: "선택"){
                    completeDateSelection()
                }
                .padding()
            }
            .presentationDetents([.fraction(0.6)]) // 60%만 차지
        }
    }
}

struct DatePickerButton_Previews: PreviewProvider {
    @State static var startDate: Date? = nil
    @State static var endDate: Date? = nil
    
    static var previews: some View {
        VStack(spacing: 16) {
            DatePickerButton(title: "시작 날짜 선택", date: $startDate) { selected in
                print("시작 날짜 선택됨: \(selected)")
            }
            DatePickerButton(title: "종료 날짜 선택", date: $endDate) { selected in
                print("종료 날짜 선택됨: \(selected)")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

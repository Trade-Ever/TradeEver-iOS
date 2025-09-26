//
//  DatePickerButton.swift
//  Trever
//
//  Created by OhChangEun on 9/17/25.
//

import SwiftUI

/**
 * 날짜 선택을 위한 커스텀 버튼 컴포넌트
 * - 시트 형태로 DatePicker를 표시
 * - 최소/최대 날짜 제한 기능
 * - 안전한 날짜 범위 검증
 */
struct DatePickerButton: View {
    let title: String                          // 버튼에 표시될 제목
    @Binding var date: Date?                   // 선택된 날짜 (양방향 바인딩)
    
    // 날짜 제한 옵션 (안전성 강화)
    let minimumDate: Date?                     // 선택 가능한 최소 날짜
    let maximumDate: Date?                     // 선택 가능한 최대 날짜
    let onDateSelected: ((Date) -> Void)?      // 날짜 선택 완료 시 콜백
    
    // 내부 상태 관리
    @State private var showPicker = false      // 시트 표시 여부
    @State private var tempDate: Date = Date() // 시트 내에서 임시로 사용할 날짜
    
    // 날짜 포맷터 (yyyy/MM/dd 형식)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    /**
     * 생성자 - 모든 매개변수를 명시적으로 정의
     * - title: 버튼 제목
     * - date: 선택된 날짜 바인딩
     * - minimumDate: 선택 가능한 최소 날짜 (nil이면 제한 없음)
     * - maximumDate: 선택 가능한 최대 날짜 (nil이면 제한 없음)
     * - onDateSelected: 날짜 선택 완료 콜백
     */
    init(title: String,
         date: Binding<Date?>,
         minimumDate: Date? = nil,
         maximumDate: Date? = nil,
         onDateSelected: ((Date) -> Void)? = nil) {
        self.title = title
        self._date = date
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.onDateSelected = onDateSelected
    }
    
    /**
     * 안전한 최소 날짜 계산
     * minimumDate가 nil인 경우 현재로부터 100년 전으로 설정
     */
    private var safeMinimumDate: Date {
        return minimumDate ?? Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }
    
    /**
     * 안전한 최대 날짜 계산
     * maximumDate가 nil인 경우 현재로부터 100년 후로 설정
     */
    private var safeMaximumDate: Date {
        return maximumDate ?? Calendar.current.date(byAdding: .year, value: 100, to: Date()) ?? Date()
    }
    
    /**
     * DatePicker에서 사용할 날짜 범위 계산
     * 최소값이 최대값보다 큰 경우를 방지하는 안전장치 포함
     */
    private var dateRange: ClosedRange<Date> {
        let minDate = safeMinimumDate
        let maxDate = safeMaximumDate
        
        // 논리적 오류 방지: 최소값 > 최대값인 경우 순서 바꿈
        if minDate > maxDate {
            return maxDate...minDate
        }
        return minDate...maxDate
    }
    
    /**
     * 안전한 초기 날짜 설정
     * 1. 기존 선택된 날짜가 있고 범위 내라면 그대로 사용
     * 2. 없거나 범위를 벗어나면 오늘 날짜 사용
     * 3. 오늘도 범위를 벗어나면 범위의 경계값 사용
     */
    private func getSafeInitialDate() -> Date {
        if let existingDate = date {
            // 기존 날짜가 유효한 범위 내에 있는지 확인
            let range = dateRange
            if range.contains(existingDate) {
                return existingDate
            }
        }
        
        // 기존 날짜가 없거나 범위를 벗어나면 안전한 기본값 사용
        let today = Date()
        let range = dateRange
        
        if range.contains(today) {
            return today                        // 오늘이 범위 내면 오늘 사용
        } else if today < range.lowerBound {
            return range.lowerBound            // 오늘이 최소값보다 이전이면 최소값 사용
        } else {
            return range.upperBound            // 오늘이 최대값보다 이후면 최대값 사용
        }
    }
    
    /**
     * 날짜 선택 완료 처리
     * - 임시 날짜를 실제 바인딩에 저장
     * - 콜백 함수 호출
     * - 시트 닫기
     */
    private func completeDateSelection() {
        date = tempDate
        onDateSelected?(tempDate)
        showPicker = false
    }
    
    var body: some View {
        Button(action: {
            // 시트 열기 전 임시 날짜를 안전한 값으로 초기화
            tempDate = getSafeInitialDate()
            showPicker = true
        }) {
            HStack {
                // 선택된 날짜가 있으면 포맷된 날짜, 없으면 제목 표시
                Text(date != nil ? dateFormatter.string(from: date!) : title)
                    .foregroundColor(date == nil ? Color.grey300.opacity(0.6) : .primary)
                Spacer()
                // 달력 아이콘 (선택 상태에 따라 색상 변경)
                Image(systemName: "calendar")
                    .foregroundColor(date != nil ? .purple300 : .grey300.opacity(0.8))
            }
            .padding()
            .background(
                // 선택 상태에 따른 테두리 색상 변경
                RoundedRectangle(cornerRadius: 8)
                    .stroke(date != nil ? Color.purple300 : Color.grey200, lineWidth: 1)
            )
        }
        // 날짜 선택 시트
        .sheet(isPresented: $showPicker) {
            VStack(spacing: 20) {
                Spacer(minLength: 60)
                
                // 그래프 스타일 날짜 피커
                DatePicker(
                    "",                         // 라벨 없음 (위에 제목이 있으므로)
                    selection: $tempDate,       // 임시 날짜와 바인딩
                    in: dateRange,              // 계산된 안전한 날짜 범위
                    displayedComponents: .date  // 날짜만 표시 (시간 제외)
                )
                .datePickerStyle(.graphical)    // 달력 스타일
                .padding(.horizontal)
                .tint(Color.purple300)          // 선택된 날짜 강조 색상
                                
                // 하단 버튼들
                HStack(spacing: 4) {
                    // 취소 버튼
                    PrimaryButton(title: "취소", isOutline: true) {
                        showPicker = false
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 선택 완료 버튼
                    PrimaryButton(title: "선택") {
                        completeDateSelection()
                    }
                }
                .padding(.bottom, 72)
                .padding(.horizontal)
            }
            .presentationDetents([.fraction(0.6)]) // 화면의 60% 높이로 표시
        }
    }
}

struct DatePickerButton_Previews: PreviewProvider {
    @State static var selectedDate: Date? = nil
    
    static var previews: some View {
        VStack(spacing: 20) {
            DatePickerButton(
                title: "시작 날짜 선택",
                date: $selectedDate,
                minimumDate: Date(), // 오늘 이후부터 가능
                maximumDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()), // 3개월 후까지
                onDateSelected: { date in
                    print("선택된 시작 날짜: \(date)")
                }
            )
            
            DatePickerButton(
                title: "종료 날짜 선택",
                date: $selectedDate,
                onDateSelected: { date in
                    print("선택된 종료 날짜: \(date)")
                }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


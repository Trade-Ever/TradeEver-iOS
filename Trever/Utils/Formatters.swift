import Foundation

enum Formatters {
    static func yearText(_ year: Int) -> String { "\(year)년식" }
    
    static func mileageText(km: Int) -> String {
        // 1만 km 단위 반올림 표기
        if km >= 10_000 {
            let man = Double(km) / 10_000.0
            let rounded = (man * 10).rounded() / 10
            return "\(rounded)만km"
        }
        return "\(km)km"
    }
    
    // Decimal comma formatter: 1234567 -> "1,234,567"
    private static let decimalNumberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "ko_KR")
        return nf
    }()

    static func decimal(_ number: Int) -> String {
        decimalNumberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    // Backward-compatible API used across views: show as 만원/억원 with commas
    static func priceText(won: Int) -> String {
        if won >= 100_000_000 { // 1억 이상
            let eok = won / 100_000_000
            let man = (won % 100_000_000) / 10_000
            if man > 0 {
                return "\(decimal(eok))억 \(decimal(man))만원"
            } else {
                return "\(decimal(eok))억원"
            }
        } else {
            let man = won / 10_000
            return "\(decimal(man))만원"
        }
    }
    
    static func timerText(until endsAt: Date) -> String {
        let remain = Int(endsAt.timeIntervalSinceNow)
        if remain <= 0 { return "종료" }
        let h = remain / 3600
        let m = (remain % 3600) / 60
        if h > 0 { return "\(h)시간 \(m)분" }
        return "\(m)분"
    }
    
    static func dateText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
    
    static func dateTimeText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f.string(from: date)
    }
    
    static func priceToEokFormat(_ value: Double) -> String {
        let intValue = Int(value)
        
        if intValue >= 10 {
            let eok = intValue / 10       // 억 단위
            let thousand = intValue % 10  // 천만원 단위 나머지
            
            if thousand == 0 {
                return "\(eok)억원"
            } else {
                return "\(eok)억 \(thousand)천만원"
            }
        } else if intValue <= 0 {
            return "0원"
        } else {
            return "\(intValue)천만원"
        }
    }
}

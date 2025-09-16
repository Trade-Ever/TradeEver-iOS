import Foundation

enum Formatters {
    static func yearText(_ year: Int) -> String { "\(year)식" }
    static func mileageText(km: Int) -> String {
        // 1만 km 단위 반올림 표기
        if km >= 10_000 {
            let man = Double(km) / 10_000.0
            let rounded = (man * 10).rounded() / 10
            return "\(rounded)만km"
        }
        return "\(km)km"
    }
    static func priceText(won: Int) -> String {
        // 억/만 단위 한국형 포맷 간단 버전
        let eok = won / 100_000_000
        let man = (won % 100_000_000) / 10_000
        if eok > 0 {
            if man > 0 { return "\(eok)억 \(man)만원" }
            return "\(eok)억원"
        }
        return "\(man)만원"
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
}

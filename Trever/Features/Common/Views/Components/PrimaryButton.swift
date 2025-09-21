import SwiftUI

/***
 아래와 같이 사용
 
    PrimaryButton(
         title: "로그인",
         action: { print("로그인") },
         fontSize: 22,
         height: 60,
         cornerRadius: 16,
     )
 */

struct PrimaryButton: View {
    var title: String
    
    // 커스텀 가능한 속성
    var fontSize: CGFloat = 20
    var fontWeight: Font.Weight = .bold
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 54
    var horizontalPadding: CGFloat = 16
    var isOutline: Bool = false // 바깥 선 UI
    
    var action: () -> Void
    
    // 버튼 눌림 상태
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundColor(isOutline ? Color.purple400 : .white)
                .frame(maxWidth: .infinity, minHeight: height)
                .background(
                    isOutline ?
                        Color.white :
                        (isPressed ? Color.purple700 : Color.purple400)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isOutline ? Color.purple400 : Color.clear, lineWidth: 2)
                )
                .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 1)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    withAnimation(.easeIn(duration: 0.1)) { isPressed = true }
                })
                .onEnded({ _ in
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
                })
        )
    }
}

// Preview
struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PrimaryButton(title: "확인") {
                print("확인 클릭")
            }
            PrimaryButton(
                title: "취소",
                isOutline: true
            ) {
                print("취소 클릭")
            }
        }
    }
}

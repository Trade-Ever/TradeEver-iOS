import SwiftUI

/***
 아래와 같이 사용
 
    CustomButton(
         title: "로그인",
         action: { print("로그인") },
         fontSize: 22,
         height: 60,
         cornerRadius: 16,
     )
 */

struct CustomButton: View {
    var title: String
    var action: () -> Void
    
    // 커스텀 가능한 속성
    var fontSize: CGFloat = 20
    var fontWeight: Font.Weight = .bold
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 54
    var horizontalPadding: CGFloat = 16
    
    // 버튼 눌림 상태
    @State private var isPressed: Bool = false
    
    var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: height)
                    .background(isPressed ? Color.purple700 : Color.purple400)
                    .cornerRadius(cornerRadius)
            }
            .buttonStyle(.plain) // 기본 버튼 애니메이션 제거 (iOS 15+)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal, horizontalPadding)
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

#Preview {
    VStack(spacing: 16) {
        CustomButton(title: "확인") {
            print("확인 버튼 클릭")
        }
        CustomButton(title: "취소") {
            print("취소 버튼 클릭")
        }
    }
}

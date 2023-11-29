import SwiftUI

struct CardAnimationButton : View {
    let isChoose: Bool
    let isProcess: Bool
    let text: String
    let color: Color
    let secondaryColor: Color
    let textColor: Color
    let onClick: () -> Unit

    var body: some View {
        
        let animated = isChoose ? 10 : 40
        let animatedSize = isChoose ? 100 : 80
        let c: Color = if (isChoose) {
            color
        } else {
            if (isProcess) {
                Color.gray
            } else {
                secondaryColor
            }
        }
        Button(action: onClick, label: {
            FullZStack {
                if (!isChoose || !isProcess) {
                    Text(text)
                        .lineLimit(1)
                        .foregroundColor(textColor)
                        .font(.system(size: CGFloat(animatedSize) / 9))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }).padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            .background(
                RoundedRectangle(cornerRadius: CGFloat(animated))
                    .fill(c)
            ).frame(width: CGFloat(animatedSize), height: CGFloat(animatedSize) / 2)
    }
}

struct FullZStack<Content> : View where Content : View {
        
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                self.content()
                Spacer()
            }
            Spacer()
        }
    }
}


extension View {
    
    @inlinable public func padding(
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) -> some View {
        return padding(
            EdgeInsets(
                top: top ?? 0,
                leading: leading ?? 0,
                bottom: bottom ?? 0,
                trailing: trailing ?? 0
            )
        )
    }
}

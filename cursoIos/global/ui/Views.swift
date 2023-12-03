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
    
    func onChange<T: Equatable>(_ it: T,_ action: @escaping (T) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            return onChange(of: it) { oldValue, newValue in
                action(newValue)
            }
        } else {
            return onChange(of: it) { newValue in
                action(newValue)
            }
        }
    }
}


struct FloatingButton: View {
    let action: () -> Void
    let icon: String
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(
                        uiImage: UIImage(
                            named: icon
                        ) ?? UIImage()
                    ).font(.system(size: 25))
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
                .background(Color.red)
                .cornerRadius(30)
                .shadow(radius: 10)
                .offset(x: -25, y: 10)
            }
        }
    }
}

struct UpperNavBar : View {
    
    //@State private var scrollPosition: Int? = 0

    let list: [String]
    let currentIndex: Int
    let theme: Theme
    let scrollTo: (ScrollViewProxy) -> Unit
    let onClick: (Int) -> Unit
    
    private func contentColor(proxy: ScrollViewProxy) -> Theme {
        scrollTo(proxy)
        return theme
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(Axis.Set.vertical) {
                LazyHStack {
                    ForEach(0...20, id: \.self) { idx in
                        OutlinedButton(action: onClick, text: list[idx], index: idx, animate: currentIndex == idx, theme: contentColor(proxy: proxy))
                    }
                }//.scrollTargetLayout()
            }//.scrollPosition(id: $scrollPosition, anchor: nil)
        }
    }
}

struct OutlinedButton : View {
    
    let action: (Int) -> Unit
    let text: String
    let index: Int
    let animate: Bool
    let theme: Theme

    private var containerColor: Color {

        animate ? theme.primary : Color.clear
    }
    
    private var contentColor: Color {
        animate ? theme.textForPrimaryColor : theme.textColor
    }
    
    var body: some View {
        Button {
            action(index)
        } label: {
            Text(text)
                .foregroundStyle(contentColor)
                .lineLimit(1)
                .frame(height: 50)
                .font(.system(size: 12))
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(containerColor,lineWidth: 1)
                ).animation(.linear(duration: 0.5), value: animate)
        }
    }
}

struct ListBody<D, Content: View> : View {
    private let list: [D]
    private var itemColor: Color = Color.clear
    private let bodyClick: (D) -> Unit
    private let content: (D) -> Content
    
    init(
        list: [D],
        itemColor: Color? = nil,
        bodyClick: @escaping (D) -> Unit,
        @ViewBuilder content: @escaping (D) -> Content
    ) {
        self.list = list
        self.itemColor = itemColor ?? self.itemColor
        self.bodyClick = bodyClick
        self.content = content
    }

    var body: some View {
        ScrollView(Axis.Set.horizontal) {
            LazyVStack {
                ForEach(list.indices, id: \.self) { idx in
                    Button {
                        bodyClick(list[idx])
                    } label: {
                        ZStack {
                            content(list[idx])
                        }.frame(height: 80)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 15).fill(itemColor)
                            )
                    }
                }
            }
        }
    }
}

struct ListBodyEdit<D, Content: View> : View {
    private let list: [D]
    private var itemColor: Color = Color.clear
    private let content: (D) -> Content
    
    init(
        list: [D],
        itemColor: Color? = nil,
        @ViewBuilder content: @escaping (D) -> Content
    ) {
        self.list = list
        self.itemColor = itemColor ?? self.itemColor
        self.content = content
    }

    var body: some View {
        ScrollView(Axis.Set.horizontal) {
            LazyVStack {
                ForEach(list.indices, id: \.self) { idx in
                    ZStack {
                        content(list[idx])
                    }.frame(height: 80)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(itemColor)
                        )
                }
            }
        }
    }
}


struct ListBodyEditAdditional<D, Content: View, Additional: View> : View {
    private let list: [D]
    private var itemColor: Color = Color.clear
    private let additionalItem: (() -> Additional)
    private let content: (D) -> Content

    init(
        list: [D],
        itemColor: Color? = nil,
        @ViewBuilder additionalItem: @escaping () -> Additional,
        @ViewBuilder content: @escaping (D) -> Content
    ) {
        self.list = list
        self.itemColor = itemColor ?? self.itemColor
        self.additionalItem = additionalItem
        self.content = content
    }

    var body: some View {
        ScrollView(Axis.Set.horizontal) {
            LazyVStack {
                additionalItem()
                ForEach(0...20, id: \.self) { idx in
                    ZStack {
                        content(list[idx])
                    }.frame(height: 80)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(itemColor)
                        )
                }
            }
        }
    }
}

struct ImageForCurveItem : View {
    let imageUri: String
    let size: CGFloat
    var body: some View {
        VStack {
            ImageView(
                urlString: imageUri
            ).frame(
                width: size, height: size, alignment: .center
            )
        }.frame(width: size, height: size, alignment: .center)
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 15,
                    topTrailingRadius: 15
                )
            )
    }
}

struct EditButton: View {
    let color: Color
    let textColor: Color
    let sideButtonClicked: () -> Unit
    
    var body: some View {
        Button {
            sideButtonClicked()
        } label: {
            VStack {
                Spacer()
                ImageAsset(icon: "edit", tint: textColor)
                Spacer()
            }.frame(width: 40, alignment: .center).background(color)
        }

    }
}

/*
 Icon(
     imageVector = Icons.Default.Edit,
     contentDescription = "Edit",
     tint = textColor
 )
fun BoxScope.EditButton(
     color: Color,
     textColor: Color,
     sideButtonClicked: () -> Unit,
 ) {
     Box(
         modifier = Modifier
             .fillMaxHeight()
             .width(40.dp)
             .align(Alignment.CenterEnd)
             .background(color)
             .clickable {
                 sideButtonClicked.invoke()
             },
         contentAlignment = Alignment.Center
     ) {
         Icon(
             imageVector = Icons.Default.Edit,
             contentDescription = "Edit",
             tint = textColor
         )
     }
 }

*/





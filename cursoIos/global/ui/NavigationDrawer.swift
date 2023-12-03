import SwiftUI

//https://itwenty.me/posts/05-swiftui-drawerview-p1/
struct DrawerView<MainContent: View, DrawerContent: View>: View {

    @Binding var isOpen: Bool
    let theme: Theme

    private let main: () -> MainContent
    private let drawer: () -> DrawerContent
    private let overlap: CGFloat = 0.7
    private let overlayColor = Color.gray.opacity(0.5)
    private let overlayOpacity = 0.7

    init(isOpen: Binding<Bool>,
         theme: Theme,
         @ViewBuilder main: @escaping () -> MainContent,
         @ViewBuilder drawer: @escaping () -> DrawerContent) {
        self._isOpen = isOpen
        self.main = main
        self.drawer = drawer
        self.theme = theme
    }

    var body: some View {
        GeometryReader { proxy in
            let drawerWidth = proxy.size.width * overlap
            ZStack(alignment: .topLeading) {
                main()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(mainOverlay)
                drawer()
                    .frame(minWidth: drawerWidth, idealWidth: drawerWidth,
                           maxWidth: drawerWidth, maxHeight: .infinity)
                    .offset(x: isOpen ? 0 : -drawerWidth, y: 0)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 20
                        )
                    )
                    //.background(theme.backDark, in: RoundedRectangle(cornerRadius: 20))
                    //.background(content: { theme.backDark.padding(.trailing, 20) })
            }
        }
    }
    
    private var mainOverlay: some View {
        overlayColor.opacity(isOpen ? overlayOpacity : 0.0)
            .onTapGesture {
                withAnimation {
                    isOpen.toggle()
                }
            }
    }
}

struct DrawerText : View {
    
    let itemColor: Color
    let text: String
    let textColor: Color
    let action: () -> Unit
    
    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                Text(text)
                    .font(.system(size: 20))
                    .foregroundStyle(textColor).padding(leading: 16, trailing: 24)
            }
            Spacer()
        }.frame(height: 56, alignment: .center).background(itemColor)
    }
}

struct DrawerItem : View {
    
    let itemColor: Color
    let icon: String
    let text: String
    let textColor: Color
    let action: () -> Unit
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(
                    uiImage: UIImage(
                        named: icon
                    )?.withTintColor(UIColor(textColor)) ?? UIImage()
                ).resizable()
                    .imageScale(.medium)
                    .scaledToFit().frame(
                        width: 25, height: 25
                    )
                Text(
                    "text"
                ).font(.system(size: 20))
                    .foregroundStyle(
                        textColor
                    )
            }
        }

    }
}

/*
 Surface(
     modifier = Modifier
         .fillMaxWidth()
         .height(
             56.0.dp//NavigationDrawerTokens.ActiveIndicatorHeight
         ),
     color = MaterialTheme.colorScheme.primary,
 ) {
     Row(
         Modifier.padding(start = 16.dp, end = 24.dp),
         verticalAlignment = Alignment.CenterVertically
     ) {
         Text(
             "Curso",
             color = isSystemInDarkTheme().textForPrimaryColor
         )
     }
 }*/

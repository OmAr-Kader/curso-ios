import SwiftUI


struct BackButtonModifier: ViewModifier {
    let onBackPressed: () -> Unit
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(action: onBackPressed)
                }
            }
    }
}

extension View {
    func withCustomBackButton(_ onBackPressed: @escaping () -> Unit) -> some View {
        modifier(BackButtonModifier(onBackPressed: onBackPressed))
    }
}


struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Spacer().frame(height: 100)
            Button(action: {
                action()
            }) {
                HStack {
                    Image(
                        uiImage: UIImage(
                            named: "chevron.backward"
                        )?.withTintColor(
                            UIColor(Color.cyan)
                        ) ?? UIImage()
                    ).resizable()
                        .imageScale(.medium)
                        .scaledToFit().frame(
                            width: 20, height: 20, alignment: .topLeading
                        )
                    Text(
                        "Back"
                    ).font(.system(size: 16))
                        .foregroundStyle(
                            Color(red: 9 / 255, green: 131 / 255, blue: 1)
                        ).padding(leading: -10)
                }
            }
        }
    }
}

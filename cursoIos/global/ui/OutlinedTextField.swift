import SwiftUI

struct OutlinedTextField : View {
    
    let text: String
    let onChange: (String) -> Unit
    let hint: String
    let isError: Bool
    let errorMsg: String
    let theme: Theme
    let lineLimit: Int?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            TextField(
                "",
                text: Binding(get: {
                    text
                }, set: { it, t in
                    onChange(it)
                })
            ).placeholder(when: text.isEmpty) {
                Text(hint).foregroundColor(theme.textHintColor)
            }.foregroundStyle(theme.textColor)
                .font(.system(size: 14))
                .padding(
                    EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 15)
                )
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(lineLimit)
            .focused($isFocused)
                .keyboardType(.emailAddress)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            isError ? theme.error : (isFocused ? theme.primary : theme.secondary),
                            lineWidth: 1.5
                        )
                )
            if isError {
                HStack {
                    Text(errorMsg).padding(
                        EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
                    ).foregroundStyle(theme.error)
                        .font(.system(size: 14))
                    Spacer()
                }
            }
        }
    }
}

extension TextField {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

import SwiftUI

struct ChatView : View {
    let isEnabled: Bool
    let chatText: String
    let theme: Theme
    let onTextChanged: (String) -> Unit
    let list: [MessageForData]
    let isUserMessage: (MessageForData) -> Bool
    let send: () -> Unit
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(Axis.Set.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(0..<list.count, id: \.self) { index in
                            let message = list[index]
                            let isThatUserMessage = isUserMessage(message)
                            if isThatUserMessage  {
                                UserMessageView(isEnabled: isEnabled, chatText: chatText, theme: theme, onTextChanged: onTextChanged, message: message, send: send)
                            } else {
                                UserRecivedMessageView(isEnabled: isEnabled, chatText: chatText, theme: theme, onTextChanged: onTextChanged, message: message, send: send)
                            }
                        }
                    }.padding(leading: 5, bottom: 7, trailing: 5)
                }.onAppear {
                    proxy.scrollTo(list.count - 1)
                }
            }
            Spacer()
            HStack(alignment: .bottom) {
                HStack(alignment: .bottom) {
                    TextField("", text: Binding(get: {
                        chatText
                    }, set: { it in
                        onTextChanged(it)
                    })).foregroundColor(theme.textColor)
                    Button(action: send, label: {
                        ImageAsset(icon: "send", tint: .gray)
                            .frame(width: 50, height: 50)
                            .padding(10)
                    }).frame(width: 50, height: 50).lineLimit(nil)
                }.background(theme.background.margeWithPrimary(0.3))
            }.shadow(radius: 3)
                .clipShape(
                    .rect(topLeadingRadius: 8, topTrailingRadius: 8)
                )
        }
    }
}

struct UserMessageView : View {
    let isEnabled: Bool
    let chatText: String
    let theme: Theme
    let onTextChanged: (String) -> Unit
    let message: MessageForData
    let send: () -> Unit
    var body: some View {
        let colorCard = message.fromStudent ? theme.secondary : theme.primary
        let colorText = theme.textForPrimaryColor
        HStack {
            Spacer()
            MessageView(message: message, colorCard: colorCard, colorText: colorText, fromColor: theme.textForPrimaryColor)
        }
    }
}

struct UserRecivedMessageView : View {
    let isEnabled: Bool
    let chatText: String
    let theme: Theme
    let onTextChanged: (String) -> Unit
    let message: MessageForData
    let send: () -> Unit
    var body: some View {
        let colorCard = message.fromStudent ? theme.backDarkThr : theme.primary
        let colorText = message.fromStudent ? theme.textColor : theme.textForPrimaryColor
        HStack {
            MessageView(message: message, colorCard: colorCard, colorText: colorText, fromColor: theme.textColor)
            Spacer()
        }
    }
}

struct MessageView :  View {
    let message: MessageForData
    let colorCard: Color
    let colorText: Color
    let fromColor: Color
    var body: some View {
        VStack {
            if message.fromStudent {
                Text("From: " + message.senderName).font(.system(size: 12))
                    .foregroundStyle(fromColor)
                    .padding(top: 2.5, leading: 10, bottom: 10, trailing: 10)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                Text(message.message).font(.system(size: 14))
                    .foregroundStyle(colorText)
                    .padding(top: 2.5, leading: 10, bottom: 2.5, trailing: 10)
                    .foregroundStyle(colorText)
            } else {
                Text(message.message).font(.system(size: 14))
                    .foregroundStyle(colorText)
                    .padding(10)
                    .foregroundStyle(colorText)
            }
        }.frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: 300).padding(5).background(
            RoundedRectangle(cornerRadius: 20).fill(colorCard)
        ).shadow(radius: 2)
    }
}

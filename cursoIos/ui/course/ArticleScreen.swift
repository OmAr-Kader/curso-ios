import SwiftUI

struct ArticleScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: ArticleObservable
    @State private var toast: Toast? = nil
    @State private var currentPage: Int = 0
    @State private var isKeyboard: Bool = false
    var articleId: String {
        return pref.getArgumentOne(it: ARTICLE_SCREEN_ROUTE) ?? ""
    }
    var articleTitle: String {
        return pref.getArgumentTwo(it: ARTICLE_SCREEN_ROUTE) ?? ""
    }
    var mode: Int {
        return pref.getArgumentThree(it: ARTICLE_SCREEN_ROUTE) ?? 0
    }
    var article: ArticleForData? {
        return pref.getArgumentJson(it: ARTICLE_SCREEN_ROUTE) as? ArticleForData
    }
    
    var list : [String] {
        return [
            "Article",
            "Chat"
        ]
    }
    var body: some View {
        let state = obs.state
            
        ZStack {
            VStack {
                if !isKeyboard {
                    Spacer().frame(height: 3)
                    ImageCacheView(state.article.imageUri)
                        .frame(height: 200).onTapGesture {
                            pref.writeArguments(
                                route: IMAGE_SCREEN_ROUTE,
                                one: state.article.imageUri,
                                two: state.article.title
                            )
                            pref.navigateTo(.IMAGE_SCREEN_ROUTE)
                        }
                } else {
                    Spacer().frame(height: 50)
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(
                        state.article.title
                    ).foregroundStyle(pref.theme.textColor)
                        .font(.system(size: 18))
                        .padding(leading: 5, trailing: 5).onStart()
                    Spacer()
                    if mode == COURSE_MODE_LECTURER {
                        CardButton(onClick: {
                            pref.writeArguments(
                                route: CREATE_ARTICLE_SCREEN_ROUTE,
                                one: state.article.id,
                                two: state.article.title
                            )
                            pref.navigateTo(.CREATE_ARTICLE_SCREEN_ROUTE)
                        }, text: "Edit", color: pref.theme.primary, textColor: pref.theme.textForPrimaryColor
                        )
                    }
                }
                Spacer().frame(height: 10)
                VStack {
                    Text(
                        state.article.lecturerName
                    ).foregroundStyle(pref.theme.textColor).padding(10).frame(minWidth: 60)
                        .font(.system(size: 12))
                }.background(RoundedRectangle(cornerRadius: 20).fill(pref.theme.backDarkThr))
                    .padding(top: 3, leading: 10, bottom: 3, trailing: 10).onStart().onTapGesture {
                        pref.writeArguments(
                            route: LECTURER_SCREEN_ROUTE,
                            one: state.article.lecturerId,
                            two: state.article.lecturerName
                        )
                        pref.navigateTo(.LECTURER_SCREEN_ROUTE)
                    }
                HStack {
                    HStack {
                        ImageAsset(icon: "reader", tint: Color.blue)
                            .padding(3)
                            .frame(width: 25, height: 25)
                        Text(state.article.readers)
                            .padding(leading: -3)
                            .foregroundStyle(pref.theme.textColor)
                            .font(.system(size: 14))
                            .lineLimit(1)
                    }.frame(alignment: .center)
                    Spacer()
                    HStack {
                        ImageAsset(icon: "star", tint: Color.blue)
                            .padding(3)
                            .frame(width: 25, height: 25)
                        Text(String(obs.articleRate))
                            .padding(leading: -3)
                            .foregroundStyle(pref.theme.textColor)
                            .font(.system(size: 14))
                            .lineLimit(1)
                    }.frame(alignment: .center)
                    Spacer()
                }
                Spacer().frame(height: 15)
                PagerTab(currentPage: currentPage, onPageChange: { it in
                    withAnimation {
                        currentPage = it
                    }
                }, list: list, theme: pref.theme) {
                    
                    TextArticleFullPageScrollable(textList: state.article.text, textColor: pref.theme.textColor).tag(0)
                    //if mode != COURSE_MODE_NONE {
                        ChatView(isEnabled: currentPage == 1, chatText: state.chatText, theme: pref.theme, onTextChanged: { it in
                            obs.changeChatText(it: it)
                        }, onKeyboardChanged: { it in
                            withAnimation {
                                isKeyboard = it
                            }
                        }, list: state.conversation?.messages ?? []) { it in
                            it.senderId == state.userId
                        } send: {
                            pref.findUserBase { userBase in
                                guard let userBase else {
                                    return
                                }
                                obs.send(mode: mode, id: userBase.id, name: userBase.name) { _ in
                                    //toast = Toast(style: .info, message: it)
                                }
                            }
                        }.tag(1)
                    //}
                }
            }
            BackButton {
                pref.backPress()
            }.onTop().onStart()
        }.background(pref.theme.background).toastView(toast: $toast).onAppear {
            pref.findUserBase { userBase in
                guard let userBase else {
                    return
                }
                obs.getArticle(article: article, articleId: articleId, studentId: userBase.id, userName: userBase.name)
                obs.getMainArticleConversation(articleId: articleId)
            }
        }
    }
}


struct TextArticleFullPageScrollable : View {
    let textList: [ArticleTextData]
    let textColor: Color
    
    var body: some View {
        //GeometryReader { geometry in
        ScrollView(Axis.Set.vertical) {
            VStack(alignment: .leading) {
                ForEach(0..<textList.count, id:\.self) { idx in
                    let art = textList[idx]
                    Text(art.text)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(textColor)
                        .font(.system(size: CGFloat(art.font)))
                        .padding(leading: 20, trailing: 20)
                        .lineLimit(nil).onStart()
                }
            }
        }
        //}
    }
}

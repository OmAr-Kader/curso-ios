import SwiftUI

struct MainItem<Content : View> : View {
    let title: String
    let imageUri: String
    let textColor: Color
    let content: () -> Content
    
    var body: some View {
        HStack {
            ImageForCurveItem(imageUri: imageUri, size: 80)
            VStack {
                Text(
                    title
                ).foregroundStyle(textColor)
                    .font(.system(size: 14))
                    .lineLimit(3)
                    .padding(top: 3, leading: 5, bottom: 5, trailing: 3)
                    .onStart()
                content()
            }.frame(alignment: .center)
            Spacer()
        }
    }
}

struct MainItemEdit<Content : View> : View {
    let title: String
    let imageUri: String
    let colorEdit: Color
    let textColor: Color
    let textColorEdit: Color
    let bodyClick: () -> Unit
    let editClick: () -> Unit
    let content: () -> Content
    
    var body: some View {
        Button {
            bodyClick()
        } label: {
            HStack {
                ImageForCurveItem(imageUri: imageUri, size: 80)
                VStack {
                    Text(
                        title
                    ).foregroundStyle(textColor)
                        .font(.system(size: 14))
                        .lineLimit(3)
                        .onStart()
                    content()
                }.frame(alignment: .center)
                Spacer()
                EditButton(
                    color: colorEdit,
                    textColor: textColorEdit,
                    sideButtonClicked: editClick
                )
            }
        }
    }
}

struct TimelineItem : View {
    
    let courseName: String
    let date: String
    let duration: String
    let textGrayColor: Color
    
    var body: some View {
        VStack {
            Text(courseName)
                .font(.system(size: 10))
                .lineLimit(1)
                .padding(leading: 15, bottom: 3, trailing: 15)
                .onStart()
            HStack {
                Text("Date: " + date)
                    .font(.system(size: 10))
                    .foregroundStyle(textGrayColor)
                    .lineLimit(1)
                Spacer()
                if !duration.isEmpty {
                   Text("Duration: " + duration)
                       .font(.system(size: 10))
                       .foregroundStyle(textGrayColor)
                       .lineLimit(1)
                }
            }.frame(alignment: .center)
                .padding(leading: 15, trailing: 15)
        }.frame(alignment: .bottom)
    }
}

struct OwnArticleItem : View {
    
    let readers: String
    let theme: Theme
    
    var body: some View {
        HStack {
            ImageAsset(icon: "profile", tint: theme.primary)
                .frame(width: 15, height: 15)
            Text(readers)
                .foregroundStyle(theme.textColor)
                .font(.system(size: 10))
                .lineLimit(1)
        }.frame(alignment: .center)
            .padding(leading: 15, bottom: 3, trailing: 15)
            .onStart()
    }
}

struct OwnCourseItem : View {

    let nextTimeLine: String
    let students: String
    let theme: Theme
    
    var body: some View {
        VStack {
            Text(nextTimeLine)
                .font(.system(size: 10))
                .foregroundStyle(theme.secondary)
                .lineLimit(1)
                .padding(leading: 15, bottom: 3, trailing: 15)
                .onStart()
            HStack {
                ImageAsset(icon: "profile", tint: theme.primary)
                    .frame(width: 15, height: 15)
                Text(students)
                    .foregroundStyle(theme.textColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.frame(alignment: .center)
                .padding(leading: 15, bottom: 3, trailing: 15)
                .onStart()
        }.frame(alignment: .center)
    }
}

struct AllCourseItem : View {
    let lecturerName: String
    let price: String
    let theme: Theme
    var body: some View {
        HStack {
            HStack {
                ImageAsset(icon: "profile", tint: theme.textColor)
                    .frame(width: 15, height: 15)
                Text(lecturerName.firstSpace.firstCapital)
                    .foregroundStyle(theme.textGrayColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.frame(alignment: .center)
                .padding(trailing: 50)
            Spacer()
            HStack {
                ImageAsset(icon: "money", tint: theme.primary)
                    .padding(3)
                    .frame(width: 15, height: 15)
                Text(price)
                    .padding(leading: -3)
                    .foregroundStyle(theme.textColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.frame(alignment: .center)
                .padding(leading: 15, bottom: 3, trailing: 15)
        }.frame(alignment: .center)
            .padding(leading: 15, bottom: 3,trailing: 15)
    }
}

struct AllArticleIem : View {
    let lecturerName: String
    let readers: String
    let theme: Theme

    var body: some View {
        HStack {
            HStack {
                ImageAsset(icon: "profile", tint: theme.textColor)
                    .frame(width: 15, height: 15)
                Text(lecturerName.firstSpace.firstCapital)
                    .foregroundStyle(theme.textGrayColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.padding(trailing: 50)
                .frame(alignment: .center)
            Spacer()
            HStack {
                ImageAsset(icon: "money", tint: theme.primary)
                    .padding(3)
                    .frame(width: 15, height: 15)
                Text(readers)
                    .padding(leading: -3)
                    .foregroundStyle(theme.textColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.padding(leading: 15, bottom: 3, trailing: 15)
                .frame(alignment: .center)
        }.frame(alignment: .center)
            .padding(leading: 15, bottom: 3,trailing: 15)
    }
}

import SwiftUI

struct MainItem<Content : View> : View {
    let title: String
    let imageUri: String
    let textColor: Color
    let content: () -> Content
    
    var body: some View {
        Button {
            bodyClick()
        } label: {
            HStack(alignment: .center) {
                ImageForCurveItem(imageUri: imageUri, size: 80)
                VStack {
                    Text(
                        title
                    ).foregroundStyle(textColor)
                        .font(.system(size: 14))
                        .lineLimit(3)
                        .padding(top: 3, leading: 5, bottom: 5, trailing: 3)
                    content()
                }.frame(alignment: .center)
                Spacer()
            }.frame(alignment: .center)
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
            HStack(alignment: .center) {
                ImageForCurveItem(imageUri: imageUri, size: 80)
                VStack {
                    Text(
                        title
                    ).foregroundStyle(textColor)
                        .font(.system(size: 14))
                        .lineLimit(3)
                        .padding(top: 3, leading: 5, bottom: 5, trailing: 3)
                    content()
                }.frame(alignment: .center)
                Spacer()
                EditButton(
                    color: colorEdit,
                    textColor: textColorEdit,
                    sideButtonClicked: editClick
                )
            }.frame(alignment: .center)
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
            HStack {
                Text("Date: " + date)
                    .font(.system(size: 10))
                    .foregroundStyle(textGrayColor)
                    .lineLimit(1)
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
        }.padding(leading: 15, bottom: 3, trailing: 15)
            .frame(alignment: .center)
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
            HStack {
                ImageAsset(icon: "profile", tint: theme.primary)
                    .frame(width: 15, height: 15)
                Text(students)
                    .foregroundStyle(theme.textColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.padding(leading: 15, bottom: 3, trailing: 15)
                .frame(alignment: .center)
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
            }.padding(trailing: 50)
                .frame(alignment: .center)
            Spacer()
            HStack {
                ImageAsset(icon: "money", tint: theme.primary)
                    .frame(width: 15, height: 15)
                Text(price)
                    .foregroundStyle(theme.textColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.padding(leading: 15, bottom: 3, trailing: 15)
                .frame(alignment: .center)
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
                    .frame(width: 15, height: 15)
                Text(readers)
                    .foregroundStyle(theme.textColor)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }.padding(leading: 15, bottom: 3, trailing: 15)
                .frame(alignment: .center)
        }.frame(alignment: .center)
            .padding(leading: 15, bottom: 3,trailing: 15)
    }
}

/*
 @Composable
 fun BoxScope.AllArticleIem(lecturerName: String, readers: String) {
     Row(
         modifier = Modifier
             .fillMaxWidth()
             .align(Alignment.BottomCenter)
             .wrapContentHeight()
             .padding(start = 15.dp, end = 15.dp, bottom = 3.dp),
         verticalAlignment = Alignment.CenterVertically,
     ) {
         Row(
             verticalAlignment = Alignment.CenterVertically,
             modifier = Modifier.padding(end = 50.dp),
         ) {
             Icon(
                 imageVector = Icons.Default.Person,
                 contentDescription = "Person",
                 tint = isSystemInDarkTheme().textColor,
                 modifier = Modifier
                     .width(15.dp)
                     .height(15.dp)
             )
             Text(
                 text = lecturerName.firstSpace.firstCapital,
                 color = isSystemInDarkTheme().textGrayColor,
                 fontSize = 10.sp,
                 maxLines = 1,
                 style = MaterialTheme.typography.bodySmall,
             )
         }
         Row(verticalAlignment = Alignment.CenterVertically) {
             Icon(
                 imageVector = Icons.Default.Person,
                 contentDescription = "Readers",
                 tint = MaterialTheme.colorScheme.primary,
                 modifier = Modifier
                     .width(15.dp)
                     .height(15.dp)
             )
             Text(
                 text = readers,
                 color = isSystemInDarkTheme().textColor,
                 fontSize = 10.sp,
                 style = MaterialTheme.typography.bodySmall,
                 maxLines = 1,
             )
         }
     }
 }

*/

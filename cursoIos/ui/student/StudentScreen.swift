import SwiftUI

struct StudentScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: StudentObservable
    @State private var toast: Toast? = nil
    @State private var currentPage: Int = 1
    var studentId: String {
        return pref.getArgumentOne(it: STUDENT_SCREEN_ROUTE) ?? ""
    }
    
    var studentName: String {
        return pref.getArgumentTwo(it: STUDENT_SCREEN_ROUTE) ?? ""
    }
    
    var body: some View {
        let state = obs.state

        ZStack {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        ImageCacheView(state.student.imageUri)
                    }.frame(width: 100, height: 100).clipShape(Circle())
                    Text(state.student.studentName.ifEmpty {
                        studentName
                    }).foregroundStyle(pref.theme.textColor).padding(leading: 5, trailing: 5).font(.system(size: 14))
                    Spacer().frame(height: 5)
                    HStack(alignment: .center) {
                        ProfileItems(
                            icon: "video",
                            color: Color.blue,
                            theme: pref.theme,
                            title: "Courses",
                            numbers: String(state.courses.count)
                        )
                        ProfileItems(
                            icon: "assignment",
                            color: Color.green,
                            theme: pref.theme,
                            title: "Certificates",
                            numbers: String(state.certificates.count)
                        )
                        ProfileItems(
                            icon: "star",
                            color: Color.yellow,
                            theme: pref.theme,
                            title: "Rate",
                            numbers: String(obs.certificatesRate)
                        )
                        PagerTab(currentPage: currentPage, onPageChange: { it in
                            currentPage = it
                        }, list: ["Timeline", "Courses","Certificates"], theme: pref.theme) {
                            StudentTimeLineView(sessions: state.sessionForDisplay, theme: pref.theme) { course in
                                pref.writeArguments(
                                    route: TIMELINE_SCREEN_ROUTE,
                                    one: "",
                                    two: "",
                                    obj: course
                                )
                                pref.navigateTo(.TIMELINE_SCREEN_ROUTE)
                            }.tag(0)
                            HomeAllCoursesView(
                                courses: state.courses,
                                theme: pref.theme
                            ) { course in
                                pref.writeArguments(
                                    route: COURSE_SCREEN_ROUTE,
                                    one: course.id,
                                    two: course.title,
                                    three: COURSE_MODE_STUDENT,
                                    obj: course
                                )
                                pref.navigateTo(.COURSE_SCREEN_ROUTE)
                            }.tag(1)
                            CertificatesView(certificates: state.certificates) { it in
                                
                            }.tag(2)
                        }
                    }
                }
            }.toastView(toast: $toast).onAppear {
                pref.findPrefString(key: PREF_USER_ID) { id in
                    if id != nil {
                        obs.fetchStudent(studentId: studentId)
                    }
               }
            }
            BackButton {
                pref.backPress()
            }
        }
    }
}


/*

 @OptIn(ExperimentalFoundationApi::class)
 @Composable
 fun StudentScreen(
     navController: NavController,
     viewModel: StudentViewModel = hiltViewModel(),
     prefModel: PrefViewModel,
     studentId: String,
     studentName: String,
 ) {
     val state = viewModel.state.value
     val scope = rememberCoroutineScope()
     val pagerState = rememberPagerState(
         initialPage = 0,
         initialPageOffsetFraction = 0f
     ) {
         3
     }
     OnLaunchScreenScope {
         viewModel.inti(studentId)
     }
     Scaffold {
         Column(
             modifier = Modifier.fillMaxSize(),
             horizontalAlignment = Alignment.CenterHorizontally,
             verticalArrangement = Arrangement.Top,
         ) {
             Spacer(modifier = Modifier.height(10.dp))
             Surface(
                 modifier = Modifier
                     .width(100.dp)
                     .height(100.dp)
                     .clip(CircleShape)
             ) {
                 SubcomposeAsyncImage(
                     model = LocalContext.current.imageBuildr(state.student.imageUri),
                     success = { (painter, _) ->
                         Image(
                             contentScale = ContentScale.Crop,
                             painter = painter,
                             contentDescription = "Image",
                             modifier = Modifier
                                 .fillMaxSize()
                         )
                     },
                     contentScale = ContentScale.FillBounds,
                     filterQuality = FilterQuality.None,
                     contentDescription = "Image",
                 )
             }
             Text(
                 text = state.student.studentName.ifEmpty {
                     studentName
                 },
                 color = isSystemInDarkTheme().textColor,
                 style = MaterialTheme.typography.bodySmall,
                 fontSize = 14.sp,
                 modifier = Modifier
                     .padding(start = 5.dp, end = 5.dp)
             )
             Row(
                 horizontalArrangement = Arrangement.SpaceBetween,
             ) {
                 ProfileItems(
                     icon = rememberVideoLibrary(color = Color.Blue),
                     color = Color.Blue,
                     title = "Courses",
                     numbers = state.courses.size.toString(),
                 )
                 ProfileItems(
                     icon = rememberAssignment(color = Color.Green),
                     color = Color.Green,
                     title = "Certificates",
                     numbers = state.certificates.size.toString(),
                 )
                 ProfileItems(
                     icon = Icons.Default.Star,
                     color = Color.Yellow,
                     title = "Rate",
                     numbers = viewModel.certificatesRate.toString(),
                 )
             }
             PagerTab(
                 pagerState = pagerState,
                 onClick = { index ->
                     scope.launch {
                         pagerState.animateScrollToPage(index)
                     }
                 },
                 list = listOf(
                     "Timeline", "Courses","Certificates",),
             ) { page: Int ->
                 when (page) {
                     0 -> StudentTimeLineView(state.sessionForDisplay) { course ->
                         scope.launch {
                             prefModel.writeArguments(TIMELINE_SCREEN_ROUTE, "", "", obj = course)
                             navController.navigate(route = TIMELINE_SCREEN_ROUTE)
                         }
                     }
                     1 -> StudentCoursesView(state.courses) { course ->
                         scope.launch {
                             prefModel.writeArguments(
                                 COURSE_SCREEN_ROUTE,
                                 course.id,
                                 course.title,
                                 COURSE_MODE_STUDENT,
                                 course
                             )
                             navController.navigate(COURSE_SCREEN_ROUTE)
                         }
                     }
                     else -> CertificatesView(state.certificates) { }
                 }
             }
         }
         BackButton {
             navController.navigateUp()
         }
     }
 }
 */

/*

 @Composable
 fun StudentCoursesView(
     courses: List<CourseForData>,
     nav: (CourseForData) -> Unit,
 ) {
     LazyColumn(modifier = Modifier.fillMaxSize()) {
         items(courses) { course ->
             Card(
                 modifier = Modifier
                     .fillMaxWidth()
                     .height(80.dp)
                     .padding(5.dp)
                     .clickable {
                         nav.invoke(course)
                     },
                 shape = RoundedCornerShape(
                     size = 15.dp
                 )
             ) {
                 Row(
                     verticalAlignment = Alignment.Top,
                     horizontalArrangement = Arrangement.SpaceBetween,
                 ) {
                     Box {
                         SubcomposeAsyncImage(
                             model = LocalContext.current.imageBuildr(course.imageUri),
                             success = { (painter, _) ->
                                 Image(
                                     contentScale = ContentScale.Crop,
                                     painter = painter,
                                     contentDescription = "Image",
                                     modifier = Modifier
                                         .clip(
                                             shape = RoundedCornerShape(
                                                 topEnd = 15.dp,
                                                 bottomEnd = 15.dp
                                             )
                                         )
                                         .width(70.dp)
                                         .height(70.dp)
                                 )
                             },
                             contentScale = ContentScale.Crop,
                             filterQuality = FilterQuality.None,
                             contentDescription = "Image"
                         )
                     }
                     Column {
                         Text(
                             text = course.title,
                             color = isSystemInDarkTheme().textColor,
                             style = MaterialTheme.typography.bodySmall,
                             fontSize = 14.sp,
                             modifier = Modifier
                                 .fillMaxWidth()
                                 .height(50.dp)
                                 .padding(start = 5.dp, end = 5.dp)
                         )
                         Row(
                             modifier = Modifier
                                 .fillMaxWidth()
                                 .height(40.dp),
                             horizontalArrangement = Arrangement.SpaceBetween,
                             verticalAlignment = Alignment.CenterVertically,
                         ) {
                             Row(
                                 modifier = Modifier
                                     .padding(end = 5.dp, start = 3.dp)
                                     .weight(1.0F),
                                 verticalAlignment = Alignment.CenterVertically,
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
                                     text = course.lecturerName,
                                     color = isSystemInDarkTheme().textColor,
                                     fontSize = 10.sp,
                                     maxLines = 1,
                                     style = MaterialTheme.typography.bodySmall,
                                 )
                             }
                             Row(
                                 verticalAlignment = Alignment.CenterVertically,
                                 modifier = Modifier.padding(end = 50.dp, start = 3.dp)
                             ) {
                                 Icon(
                                     imageVector = rememberAttachMoney(color = MaterialTheme.colorScheme.primary),
                                     contentDescription = "Money",
                                     tint = MaterialTheme.colorScheme.primary,
                                     modifier = Modifier
                                         .width(15.dp)
                                         .height(15.dp)
                                 )
                                 Text(
                                     text = course.price,
                                     color = isSystemInDarkTheme().textColor,
                                     fontSize = 10.sp,
                                     style = MaterialTheme.typography.bodySmall,
                                     maxLines = 1,
                                 )
                             }
                         }
                     }
                 }
             }
         }
     
*/

struct CertificatesView : View {
    let certificates: [Certificate]
    let nav: (String) -> Unit
    var body: some View {
        ScrollView {
            ForEach(0..<certificates.count, id: \.self) { idx in
                HStack {
                    
                }.frame(height: 80).clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}
                
/*
@Composable
func CertificatesView(
    certificates: List<Certificate>,
    nav: (route: String) -> Unit,
) {
    LazyColumn(modifier = Modifier.fillMaxSize()) {
        items(certificates) { certificate ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(80.dp)
                    .padding(5.dp)
                    .clickable {

                    },
                shape = RoundedCornerShape(
                    size = 15.dp
                )
            ) {
                Row(
                    verticalAlignment = Alignment.Top,
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Box {
                        Icon(
                            imageVector = Icons.Default.Star,
                            contentDescription = "Image",
                            tint = rateColor(certificate.rate),
                            modifier = Modifier
                                .width(70.dp)
                                .padding(20.dp)
                                .height(70.dp)
                        )
                    }
                    Column {
                        Text(
                            text = certificate.title,
                            color = isSystemInDarkTheme().textColor,
                            style = MaterialTheme.typography.bodySmall,
                            fontSize = 14.sp,
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(start = 5.dp, end = 5.dp)
                        )
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(40.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Row(
                                modifier = Modifier
                                    .padding(end = 5.dp, start = 3.dp)
                                    .weight(1.0F),
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Icon(
                                    imageVector = Icons.Default.DateRange,
                                    contentDescription = "Person",
                                    tint = isSystemInDarkTheme().textColor,
                                    modifier = Modifier
                                        .width(15.dp)
                                        .height(15.dp)
                                )
                                Text(
                                    text = certificate.date.toString,
                                    color = isSystemInDarkTheme().textColor,
                                    fontSize = 10.sp,
                                    maxLines = 1,
                                    style = MaterialTheme.typography.bodySmall,
                                )
                            }
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.padding(end = 50.dp, start = 3.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Star,
                                    contentDescription = "Money",
                                    tint = Color.Yellow,
                                    modifier = Modifier
                                        .width(15.dp)
                                        .height(15.dp)
                                )
                                Text(
                                    text = certificate.rate.toString(),
                                    color = isSystemInDarkTheme().textColor,
                                    fontSize = 10.sp,
                                    style = MaterialTheme.typography.bodySmall,
                                    maxLines = 1,
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}*/

import SwiftUI

struct Theme {
    let isDarkMode: Bool
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let onPrimary: Color
    let onSecondary: Color
    let onBackground: Color
    let onSurface: Color
    let backDark: Color
    let backDarkSec: Color
    let backDarkThr: Color
    let backGreyTrans: Color
    let textColor: Color
    let textGrayColor: Color
    let error: Color
    let textHintColor: Color
   
    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        if (isDarkMode) {
            self.primary = Purple80
            self.secondary = PurpleGrey80
            self.background = DarkGray
            self.surface = DarkGray
            self.onPrimary = Color.white
            self.onSecondary = BackSecDark
            self.onBackground = Color(red: 28, green: 27, blue: 31)
            self.onSurface = Color.white
            self.backDark = Color(red: 31, green: 31, blue: 31)
            self.backDarkSec = Color(red: 61, green: 61, blue: 61)
            self.backDarkThr = Color(red: 100, green: 100, blue: 100)
            self.backGreyTrans = Color(red: 89, green: 85, blue: 85, opacity: 0.33)
            self.textColor = Color.white
            self.textGrayColor = Color(UIColor.lightGray)
            self.error = Color(red: 255, green: 21, blue: 21)
            self.textHintColor = Color(red: 175, green: 175, blue: 175)
        } else {
            self.primary = Purple40
            self.secondary = PurpleGrey40
            self.background = LightViolet
            self.surface = LightViolet
            self.onPrimary = Color.black
            self.onSecondary = BackSec
            self.onBackground = Color(red: 28, green: 27, blue: 31)
            self.onSurface = Color.black
            self.backDark = Color.white
            self.backDarkSec = Color(red: 201, green: 201, blue: 201)
            self.backDarkThr = Color(red: 172, green: 172, blue: 172)
            self.backGreyTrans = Color(red: 89, green: 170, blue: 170, opacity: 0.67)
            self.textColor = Color.black
            self.textGrayColor = Color(UIColor.darkGray)
            self.error = Color(red: 155, green: 0, blue: 0)
            self.textHintColor = Color(red: 80, green: 80, blue: 80)
        }
    }
}

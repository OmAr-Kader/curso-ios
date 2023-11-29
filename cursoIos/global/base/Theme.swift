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
    let textForPrimaryColor: Color
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
            self.onBackground = Color(red: 28 / 255, green: 27 / 255, blue: 31 / 255)
            self.onSurface = Color.white
            self.backDark = Color(red: 31 / 255, green: 31 / 255, blue: 31 / 255)
            self.backDarkSec = Color(red: 61 / 255, green: 61 / 255, blue: 61 / 255)
            self.backDarkThr = Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255)
            self.backGreyTrans = Color(red: 89 / 255, green: 85 / 255, blue: 85 / 255, opacity: 0.33)
            self.textColor = Color.white
            self.textForPrimaryColor = Color.black
            self.textGrayColor = Color(UIColor.lightGray)
            self.error = Color(red: 255 / 255, green: 21 / 255, blue: 21 / 255)
            self.textHintColor = Color(red: 175 / 255, green: 175 / 255, blue: 175 / 255)
        } else {
            self.primary = Purple40
            self.secondary = PurpleGrey40
            self.background = LightViolet
            self.surface = LightViolet
            self.onPrimary = Color.black
            self.onSecondary = BackSec
            self.onBackground = Color(red: 28 / 255, green: 27 / 255, blue: 31 / 255)
            self.onSurface = Color.black
            self.backDark = Color.white
            self.backDarkSec = Color(red: 201 / 255, green: 201 / 255, blue: 201 / 255)
            self.backDarkThr = Color(red: 172 / 255, green: 172 / 255, blue: 172 / 255)
            self.backGreyTrans = Color(red: 89 / 255, green: 170 / 255, blue: 170, opacity: 0.67)
            self.textColor = Color.black
            self.textForPrimaryColor = Color.white
            self.textGrayColor = Color(UIColor.darkGray)
            self.error = Color(red: 155 / 255, green: 0, blue: 0)
            self.textHintColor = Color(red: 80 / 255, green: 80 / 255, blue: 80 / 255)
        }
    }
    
    func textFieldColor(isError: Bool, isEmpty: Bool) -> Color {
        if (isError) {
            return error
        } else {
            return isEmpty ? Color.black.opacity(0.7) : Color.black
        }
    }
}

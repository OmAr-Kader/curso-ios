import SwiftUI

extension Color {
    var darker: Color {
        return Color(
            UIColor(self) * 0.85 + .black * 0.15
        )
    }

    func darker(f: Double = 0.15) -> Color {
        return Color(
            UIColor(self) * (1.0 - f) + .black * f
        )
    }
}

func addColor(_ color1: UIColor, with color2: UIColor) -> UIColor {
    var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

    color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    // add the components, but don't let them go above 1.0
    return UIColor(red: min(r1 + r2, 1), green: min(g1 + g2, 1), blue: min(b1 + b2, 1), alpha: (a1 + a2) / 2)
}

func multiplyColor(_ color: UIColor, by multiplier: CGFloat) -> UIColor {
    var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return UIColor(red: r * multiplier, green: g * multiplier, blue: b * multiplier, alpha: a)
}

func +(color1: UIColor, color2: UIColor) -> UIColor {
    return addColor(color1, with: color2)
}

func *(color: UIColor, multiplier: Double) -> UIColor {
    return multiplyColor(color, by: CGFloat(multiplier))
}

func rateColor(rate: Double) -> Color {
    return Color(UIColor(.yellow) * 0.5 + .darkGray * 0.5)
}

/*
var textForPrimaryColor: Color
    get() = if (this) Color.Black else Color.White


@androidx.compose.runtime.Composable
fun Bool.outlinedTextFieldStyle(): androidx.compose.material3.TextFieldColors = androidx.compose.material3.OutlinedTextFieldDefaults.colors(
    focusedBorderColor = MaterialTheme.colorScheme.secondary,
    errorBorderColor = error,
    unfocusedBorderColor = textColor,
    focusedPlaceholderColor = Color.Gray,
    focusedTextColor = textColor,
    unfocusedTextColor = textColor,
)

@androidx.compose.runtime.Composable
fun Bool.outlinedDisabledStyle(isError: Bool): androidx.compose.material3.TextFieldColors = androidx.compose.material3.OutlinedTextFieldDefaults.colors(
    focusedBorderColor = MaterialTheme.colorScheme.secondary,
    disabledBorderColor = if (isError) error else  textColor,
    disabledLabelColor = textColor,
    disabledPlaceholderColor = textColor,
    disabledContainerColor = Color.Transparent,
    disabledTextColor = textColor,
    errorBorderColor = error,
    unfocusedBorderColor = textColor,
    focusedPlaceholderColor = Color.Gray,
    focusedTextColor = textColor,
    unfocusedTextColor = textColor,
)*/
/*
let Bool.backDark: Color
    get() = if (this) Color(0x1F1F1F) else Color.White

let Bool.backDarkSec: Color
    get() = if (this) Color(0x3D3D3D) else Color(0xC9C9C9)

let Bool.backDarkThr: Color
    get() = if (this) Color(0x646464) else Color(0xACACAC)

let Bool.backGreyTrans: Color
    get() = if (this) Color(0x59555555) else Color(0x59AAAAAA)

let Bool.textColor: Color
    get() = if (this) Color.White else Color.Black

let Bool.textGrayColor: Color
    get() = if (this) Color.LightGray else Color.DarkGray

let Bool.error: Color
    get() = if (this) Color(0xFF1515) else Color(0x9B0000)

let Bool.textHintColor: Color
    get() = if (this) Color(0xAFAFAF) else Color(0x505050)
*/

var shadowColor: Color {
    return Color(red: 0, green: 0, blue: 0, opacity: 50)
}

var Purple80: Color {
    return Color(red: 208, green: 188, blue: 255)
}
var PurpleGrey80: Color {
    return Color(red: 204,green: 194, blue: 220)
}
var Pink80: Color {
    return Color(red: 239,green: 184, blue: 200)
}

var Purple40: Color {
    return Color(red: 102, green: 80, blue: 164)
}

var PurpleGrey40: Color {
    return Color(red: 98, green: 91, blue: 113)
}

var Pink40: Color {
    return Color(red: 125, green: 82, blue: 96)
}

var Green: Color {
    return Color(red: 1, green: 189, blue: 1)
}

var Blue: Color {
    return Color(red: 13, green: 23, blue: 213)
}

var DarkGray: Color {
    return Color(red: 32, green: 32, blue: 32)
}

var LightViolet: Color {
    return Color(red: 229, green: 215, blue: 232)
}

var Yellow: Color {
    return Color(red: 224, green: 224, blue: 12)
}

var BackSec: Color {
    return Color(red: 61, green: 61, blue: 61)
}

var BackSecDark: Color {
    return Color(red: 201, green: 201, blue: 201)
}

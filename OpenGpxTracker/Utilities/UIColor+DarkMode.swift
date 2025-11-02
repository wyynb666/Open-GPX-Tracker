//
//  UIColor+DarkMode.swift
//  OpenGpxTracker
//

import UIKit

@available(iOS 13.0, *)
/// UIColor extensions for Dark Mode support
extension UIColor {
    
    /// Main UI color
    static let mainUIColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            return UIColor(red: 0, green: 0.61, blue: 0.86, alpha: 1)
        case .dark:
            return .white
        default:
            return UIColor(red: 0, green: 0.61, blue: 0.86, alpha: 1)
        }
    }
    
    // 返回与特征集合相反的颜色
    static let blackAndWhite = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            return .black
        case .dark:
            return .white
        default:
            return .systemGray
        }
    }

    static let keyboardColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            return .lightKeyboard
        case .dark:
            return .darkKeyboard
        default:
            return .lightKeyboard
        }
    }
    
    static let highlightKeyboardColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            return .highlightLightKeyboard
        case .dark:
            return .highlightDarkKeyboard
        default:
            return .highlightLightKeyboard
        }
    }
    
}

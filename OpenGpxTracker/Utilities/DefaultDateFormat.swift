//
//  DefaultDateFormat.swift
//  OpenGpxTracker
//

import Foundation

// 处理“未处理”用户输入日期格式的处理、示例日期格式的处理等
class DefaultDateFormat {

    let dateFormatter = DateFormatter()

    func getDateFormat(unprocessed: String) -> (String, Bool) {
        var newText = ""
        var isInvalid = false

        // 防止确认未终止的日期格式有效
        if (unprocessed.countInstances(of: "{") != unprocessed.countInstances(of: "}"))
        || unprocessed.countInstances(of: "{}") > 0 {
            newText = "'invalid'"
            isInvalid = true
        } else {
            let arr = unprocessed.components(separatedBy: CharacterSet(charactersIn: "{}"))
            var lastField: String?
            let arrCount = arr.count
            for i in 0...arrCount - 1 {
                if let lastField = lastField, lastField.countInstances(of: String(arr[i].last ?? Character(" "))) > 0 {
                    newText = "'invalid: { ... } must not consecutively repeat'"
                    isInvalid = true
                    break
                }
                if arr.count == 1 {
                    newText += "'invalid'"
                    isInvalid = true
                } else if arrCount > 1 && !arr[i].isEmpty {
                    newText += (i % 2 == 0) ? "'\(arr[i])'" : arr[i]
                    lastField = (i % 2 != 0) ? arr[i] : nil
                }
            }
        }
        return (newText, isInvalid)
    }
    
    // 根据用户输入返回示例日期时间。
    func getDate(processedFormat dateFormat: String, useUTC: Bool = false, useENLocale: Bool = false) -> String {
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = useUTC ? TimeZone(secondsFromGMT: 0) : TimeZone.current
        dateFormatter.locale = useENLocale ? Locale(identifier: "en_US_POSIX") : Locale.current
        return dateFormatter.string(from: Date())
    }
    
    // 从用户首选项获取格式化的当前日期字符串
    func getDateFromPrefs() -> String {
        let dateFormat = Preferences.shared.dateFormat
        let useUTC = Preferences.shared.dateFormatUseUTC
        let useEN = Preferences.shared.dateFormatUseEN
        return getDate(processedFormat: dateFormat, useUTC: useUTC, useENLocale: useEN)
        
    }

}

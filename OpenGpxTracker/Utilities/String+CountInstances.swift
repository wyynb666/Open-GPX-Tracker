//
//  String+CountInstances.swift
//  OpenGpxTracker
//

import Foundation

/// 计算出现次数
extension String {
    /// 计算stringToFind的实例数;必须至少包含1个字符
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: [.literal], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
    
}

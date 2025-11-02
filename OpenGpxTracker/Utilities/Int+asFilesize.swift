//
//  Int+inKB.swift
//  OpenGpxTracker
//

import Foundation

extension Int {
    
    // 格式化文件大小显示 1024 -> 1KB
    func asFileSize() -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self))
        // print("formatted result: \(string)")
        return string
    }
}

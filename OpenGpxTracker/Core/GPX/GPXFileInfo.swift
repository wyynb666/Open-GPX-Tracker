//
//  GPXFileInfo.swift
//  OpenGpxTracker
//

import Foundation

class GPXFileInfo: NSObject {

    var _modifiedDate: Date?

    var _fileSize: Int?

    var fileURL: URL = URL(fileURLWithPath: "")

    var modifiedDate: Date {
        if _modifiedDate != nil {
            return _modifiedDate!
        }
        guard let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
              let _modifiedDate = resourceValues.contentModificationDate else {
            return Date.distantPast
        }
        return _modifiedDate
    }

    var modifiedDatetimeAgo: String {
        return modifiedDate.timeAgo(numericDates: true)
    }

    var fileSize: Int {
        if (_fileSize != nil) {
            return _fileSize!
        }
        guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
              let _filesize = resourceValues.fileSize else {
            return -1
        }
        return _filesize
    }

    var fileSizeHumanised: String {
        return fileSize.asFileSize()
    }

    var fileName: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
    
}

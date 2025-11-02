//
//  DateField.swift
//  OpenGpxTracker
//

import Foundation

struct DateField {
    
    /// Title/type of the pattern (e.g. Year / Second)
    var type: String
    /// Patterns of that falls under said type (e.g `YYYY` / `ss`)
    var patterns: [String]
    /// Key of subtitle should be accessible in `patterns`
    var subtitles: [String: String]?
}

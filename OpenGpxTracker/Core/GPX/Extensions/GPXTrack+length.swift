//
//  GPXTrack+length.swift
//  OpenGpxTracker
//

import Foundation
import MapKit
import CoreGPX

// 计算GPXTrack中所有轨迹段的总长度
extension GPXTrack {
    
    // 计算所有轨迹段的总长度
    public var length: CLLocationDistance {
        var trackLength: CLLocationDistance = 0.0
        for segment in segments {
            trackLength += segment.length()
        }
        return trackLength
    }    
}

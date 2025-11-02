//
//  GPXRoot+length.swift
//  OpenGpxTracker
//

import Foundation
import MapKit
import CoreGPX

// 计算GPXRoot中所有轨迹段的总长度
extension GPXRoot {
    
    // 计算所有轨迹段的总长度
    public var tracksLength: CLLocationDistance {
        var tLength: CLLocationDistance = 0.0
        for track in self.tracks {
            tLength += track.length
        }
        return tLength
    }
}

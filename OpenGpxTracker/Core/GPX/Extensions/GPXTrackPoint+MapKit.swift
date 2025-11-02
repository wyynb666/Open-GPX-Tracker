//
//  GPXPoint+MapKit.swift
//  OpenGpxTracker
//

import Foundation
import UIKit
import MapKit
import CoreGPX

// 通过CLLocation数据初始化GPXTrackPoint
extension GPXTrackPoint {

    // 使用CLLocation数据初始化GPXTrackPoint
    convenience init(location: CLLocation) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.time = Date()
        self.elevation = location.altitude
    }
}

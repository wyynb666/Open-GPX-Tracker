//
//  GPXTrackSegment+MapKit.swift
//  OpenGpxTracker
//

import Foundation
import UIKit
import MapKit
import CoreGPX

// 此扩展添加了一些与 MapKit 配合使用的方法
#if os(iOS)
extension GPXTrackSegment {
    
    // 返回包含线段点的MapKit多段线
    // 该折线可以直接作为叠加层绘制在地图上
    public var overlay: MKPolyline {
        var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
        let pl = MKPolyline(coordinates: &coords, count: coords.count)
        return pl
    }
}
#endif

extension GPXTrackSegment {
  
    // Helper方法来创建多段线。返回点的坐标数组
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for point in self.points {
            coords.append(point.coordinate)
        }
        return coords
    }
    
    // 计算轨迹段的总长度
    func length() -> CLLocationDistance {
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance

        if self.points.count < 2 {
            return length
        }
        var prev: CLLocation?
        for point in self.points {
            let pt: CLLocation = CLLocation(latitude: Double(point.latitude!), longitude: Double(point.longitude!) )
            if prev == nil {
                prev = pt
                continue
            }
            distanceTwoPoints = pt.distance(from: prev!)
            length += distanceTwoPoints

            prev = pt
        }
        return length
    }    
}

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreGPX
import CoreData
import MapCache

class GPXMapView: MKMapView {
    
    // GPX位置记录的当前会话
    let session = GPXSession()

    // 地图上显示的与当前路段对应的路线
    var currentSegmentOverlay: MKPolyline
    
    // GPX点和轨迹的范围
    var extent: GPXExtentCoordinates = GPXExtentCoordinates()
    
    // 地图上的位置
    var compassRect: CGRect
    
    var useCache: Bool = true {
        didSet {
            if tileServerOverlay is CachedTileOverlay {
                print("GPXMapView:: setting useCache \(useCache)")
                (tileServerOverlay as! CachedTileOverlay).useCache = useCache
            }
        }
    }
    
    // 人物箭头朝向
    var headingImageView: UIImageView?
    
    // 选定的瓦片服务器
    var tileServer: GPXTileServer = .apple {
        willSet {
            print("Setting map tiles overlay to: \(newValue.name)" )
            updateMapInformation(newValue)
            if tileServer != .apple {
                removeOverlay(tileServerOverlay)
            }
            
            if newValue != .apple && newValue != .appleSatellite {
                var config = MapCacheConfig(withUrlTemplate: newValue.templateUrl)
                config.subdomains = newValue.subdomains
                config.tileSize = CGSize(width: newValue.tileSize, height: newValue.tileSize)
                if newValue.maximumZ > 0 {
                    config.maximumZ = newValue.maximumZ
                }
                if newValue.minimumZ > 0 {
                    config.minimumZ = newValue.minimumZ
                }
                let cache = MapCache(withConfig: config)
                
                tileServerOverlay = useCache(cache, canReplaceMapContent: newValue.canReplaceMapContent)
            } else {
                self.mapType = (newValue == .apple) ? .standard : .satellite
            }
        }
        didSet {
            if #available(iOS 13, *) {
                if tileServer == .apple {
                    overrideUserInterfaceStyle = .unspecified
                    NotificationCenter.default.post(name: .updateAppearance, object: nil, userInfo: nil)
                } else {
                    overrideUserInterfaceStyle = .light
                    NotificationCenter.default.post(name: .updateAppearance, object: nil, userInfo: nil)
                }
            }
        }
    }
    
    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    
    let coreDataHelper = CoreDataHelper()
    
    var heading: CLHeading?
    
    var headingOffset: CGFloat?
    
    var rotationGesture = UIRotationGestureRecognizer()
    
    // 初始化地图，当前路段覆盖层为空
    required init?(coder aDecoder: NSCoder) {
        var tmpCoords: [CLLocationCoordinate2D] = [] // Init with empty
        currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        compassRect = CGRect.init(x: 0, y: 0, width: 36, height: 36)
        super.init(coder: aDecoder)
        
        // 旋转手势
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureHandling(_:)))
        
        addGestureRecognizer(rotationGesture)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        
        if #available(iOS 11, *) {
            self.showsCompass = false
        }
    }
    
    // 重写默认实现
    override func layoutSubviews() {
        super.layoutSubviews()
        if let compassView = subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!) }).first {
            if compassRect.origin.x != 0 {
                compassView.frame = compassRect
            }
        }
        
        updateMapInformation(tileServer)
    }
    
    func updateMapInformation(_ tileServer: GPXTileServer) {
        if let logoClass = NSClassFromString("MKAppleLogoImageView"),
           let mapLogo = subviews.filter({ $0.isKind(of: logoClass) }).first {
            mapLogo.isHidden = (tileServer != .apple)
        }
        
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = subviews.filter({ $0.isKind(of: textClass) }).first {
            mapText.isHidden = (tileServer != .apple)
        }
    }
    
    /// 处理检测到的用户旋转操作，用于更新方向箭头
    @objc func rotationGestureHandling(_ gesture: UIRotationGestureRecognizer) {
        headingOffset = gesture.rotation
        updateHeading()
        
        if gesture.state == .ended {
            headingOffset = nil
        }
    }
    
    // 在作为参数传递的点上添加航点标注
    func addWaypointAtViewPoint(_ point: CGPoint) {
        let coords: CLLocationCoordinate2D = convert(point, toCoordinateFrom: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        addWaypoint(waypoint)
        coreDataHelper.add(toCoreData: waypoint)
        
    }
    
    // add一个waypoint
    func addWaypoint(_ waypoint: GPXWaypoint) {
    	session.addWaypoint(waypoint)
        addAnnotation(waypoint)
        extent.extendAreaToIncludeLocation(waypoint.coordinate)
    }
    
    // Removes a Waypoint
    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = session.waypoints.firstIndex(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        } 
        removeAnnotation(waypoint)
        session.waypoints.remove(at: index!)
        coreDataHelper.deleteWaypoint(fromCoreDataAt: index!)
    }
    

    // 更新航向箭头
    func updateHeading() {
        guard let heading = heading else { return }
        
        headingImageView?.isHidden = false
        let rotation = CGFloat((heading.trueHeading - camera.heading)/180 * Double.pi)
        
        var newRotation = rotation
        
        if let headingOffset = headingOffset {
            newRotation = rotation + headingOffset
        }
 
        UIView.animate(withDuration: 0.15) {
            self.headingImageView?.transform = CGAffineTransform(rotationAngle: newRotation)
        }
    }
    
    // 添加点
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
    let pt = GPXTrackPoint(location: location)
        coreDataHelper.add(toCoreData: pt, withTrackSegmentID: session.trackSegments.count)
        session.addPointToCurrentTrackSegmentAtLocation(location)

        removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = session.currentSegment.overlay
        
        addOverlayOnTop(currentSegmentOverlay)

        print("[OVERLAYS] \(overlays)")
        extent.extendAreaToIncludeLocation(location.coordinate)
    }

    func startNewTrackSegment() {
        if session.currentSegment.points.count > 0 {
            session.startNewTrackSegment()
            currentSegmentOverlay = MKPolyline()
        }
    }
    
    // 结束
    func finishCurrentSegment() {
        startNewTrackSegment()
    }
    
    // clear map
    func clearMap() {
        session.reset()
        removeOverlays(overlays)
        removeAnnotations(annotations)
        extent = GPXExtentCoordinates()
        
        if tileServer != .apple {
            addOverlayOnBottom(tileServerOverlay)
        }
    }
    
    func exportToGPXString() -> String {
        return session.exportToGPXString()
    }

    func regionToGPXExtent() {
        setRegion(extent.region, animated: true)
    }
    
    // 导入 GPX
    func importFromGPXRoot(_ gpx: GPXRoot) {
        clearMap()
        addWaypoints(for: gpx)
        addTrackSegments(for: gpx)
    }

    private func addWaypoints(for gpx: GPXRoot, fromImport: Bool = true) {
        for waypoint in gpx.waypoints {
            addWaypoint(waypoint)
            if fromImport {
                coreDataHelper.add(toCoreData: waypoint)
            }
        }
    }

    private func addTrackSegments(for gpx: GPXRoot) {
        session.tracks = gpx.tracks
        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.segments {
                let overlay = segment.overlay
                addOverlayOnTop(overlay)
                let segmentTrackpoints = segment.points
                // Add point to map extent
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
        clearMap()
        addWaypoints(for: gpx, fromImport: false)
        
        session.continueFromGPXRoot(gpx)

        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.segments {
                let overlay = segment.overlay
                addOverlayOnTop(overlay)
                
                let segmentTrackpoints = segment.points
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
        
        for trackSegment in session.trackSegments {
            
            let overlay = trackSegment.overlay
            addOverlayOnTop(overlay)
            
            let segmentTrackpoints = trackSegment.points

            for waypoint in segmentTrackpoints {
                extent.extendAreaToIncludeLocation(waypoint.coordinate)
            }
        }
        
    }
}

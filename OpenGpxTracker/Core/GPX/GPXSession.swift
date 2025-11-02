import Foundation
import CoreGPX
import CoreLocation

#if os(iOS)
// GPX创建者标识符
let kGPXCreatorString = "Open GPX Tracker for iOS"
#elseif os(watchOS)
let kGPXCreatorString = "Open GPX Tracker for watchOS"
typealias GPXMapView = GPXSession
#endif

class GPXSession {

    var waypoints: [GPXWaypoint] = []
    var tracks: [GPXTrack] = []
    var trackSegments: [GPXTrackSegment] = []
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    var totalTrackedDistance = 0.00
    var currentTrackDistance = 0.00
    var currentSegmentDistance = 0.00

    func addWaypoint(_ waypoint: GPXWaypoint) {
        self.waypoints.append(waypoint)
    }

    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = waypoints.firstIndex(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        }
        waypoints.remove(at: index!)
    }

    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.add(trackpoint: pt)

        if self.currentSegment.points.count >= 2 { // At elast there are two points in the segment
            let prevPt = self.currentSegment.points[self.currentSegment.points.count-2] // Get previous point
            guard let latitude = prevPt.latitude, let longitude = prevPt.longitude else { return }
            let prevPtLoc = CLLocation(latitude: latitude, longitude: longitude)
            // Now get the distance
            let distance = prevPtLoc.distance(from: location)
            self.currentTrackDistance += distance
            self.totalTrackedDistance += distance
            self.currentSegmentDistance += distance
        }
    }

    func startNewTrackSegment() {
        if self.currentSegment.points.count > 0 {
            self.trackSegments.append(self.currentSegment)
            self.currentSegment = GPXTrackSegment()
            self.currentSegmentDistance = 0.00
        }
    }

    func reset() {
        self.trackSegments = []
        self.tracks = []
        self.currentSegment = GPXTrackSegment()
        self.waypoints = []
        
        self.totalTrackedDistance = 0.00
        self.currentTrackDistance = 0.00
        self.currentSegmentDistance = 0.00
        
    }

    func exportToGPXString() -> String {
        print("Exporting session data into GPX String")
        // 创建gpx结构
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.add(waypoints: self.waypoints)
        let track = GPXTrack()
        track.add(trackSegments: self.trackSegments)

        if self.currentSegment.points.count > 0 {
            track.add(trackSegment: self.currentSegment)
        }

        gpx.add(tracks: self.tracks)
        gpx.add(track: track)
        return gpx.gpx()
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
        
        let lastTrack = gpx.tracks.last ?? GPXTrack()
        totalTrackedDistance += lastTrack.length

        self.tracks = gpx.tracks
        self.trackSegments = lastTrack.segments

        if self.tracks.count > 0 {
            self.tracks.removeLast()
        }
        
    }
    
}

//
//  CoreDataHelper+FetchRequests.swift
//  OpenGpxTracker
//

import CoreData
import CoreGPX

extension CoreDataHelper {
    
    func rootFetchRequest() -> NSAsynchronousFetchRequest<CDRoot> {
        let rootFetchRequest = NSFetchRequest<CDRoot>(entityName: "CDRoot")
        let asyncRootFetchRequest = NSAsynchronousFetchRequest(fetchRequest: rootFetchRequest) { asynchronousFetchResult in
            guard let rootResults = asynchronousFetchResult.finalResult else { return }
            
            DispatchQueue.main.async {
                print("Core Data Helper: fetching recoverable CDRoot")
                guard let objectID = rootResults.last?.objectID else { self.lastFileName = ""; return }
                guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDRoot else { self.lastFileName = ""; return }
                self.lastFileName = safePoint.lastFileName ?? ""
                self.lastTracksegmentId = safePoint.lastTrackSegmentId
                self.isContinued = safePoint.continuedAfterSave
                print("Core Data Helper: fetched CDRoot  lastFileName:\(self.lastFileName) lastTracksegmentId: \(self.lastTracksegmentId) isContinued: \(self.isContinued)")
            }
        }
        return asyncRootFetchRequest
    }

    func trackPointFetchRequest() -> NSAsynchronousFetchRequest<CDTrackpoint> {
        // Creates a fetch request
        let trkptFetchRequest = NSFetchRequest<CDTrackpoint>(entityName: "CDTrackpoint")
        // 确保获取的数据已排序
        let sortTrkpt = NSSortDescriptor(key: "trackpointId", ascending: true)
        trkptFetchRequest.sortDescriptors = [sortTrkpt]

        let asynchronousTrackPointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trkptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable CDTrackpoints")
            
            guard let trackPointResults = asynchronousFetchResult.finalResult else { return }
            DispatchQueue.main.async {
                self.tracksegmentId = trackPointResults.first?.trackSegmentId ?? 0
                
                for result in trackPointResults {
                    let objectID = result.objectID

                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDTrackpoint else { continue }
                    
                    if self.tracksegmentId != safePoint.trackSegmentId {
                        if self.currentSegment.points.count > 0 {
                            self.tracksegments.append(self.currentSegment)
                            self.currentSegment = GPXTrackSegment()
                        }
                        
                        self.tracksegmentId = safePoint.trackSegmentId
                    }
                    
                    let pt = GPXTrackPoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    
                    pt.time = safePoint.time
                    pt.elevation = safePoint.elevation
                    
                    self.currentSegment.points.append(pt)
                    
                }
                self.trackpointId = trackPointResults.last?.trackpointId ?? Int64()
                self.tracksegments.append(self.currentSegment)

                print("Core Data Helper: fetched CDTrackpoints. # of tracksegments: \(self.tracksegments.count). trackPointId: \(self.trackpointId) trackSegmentId: \(self.tracksegmentId)")
            }
        }
        return asynchronousTrackPointFetchRequest
    }
    
    func waypointFetchRequest() -> NSAsynchronousFetchRequest<CDWaypoint> {
        let wptFetchRequest = NSFetchRequest<CDWaypoint>(entityName: "CDWaypoint")
        let sortWpt = NSSortDescriptor(key: "waypointId", ascending: true)
        wptFetchRequest.sortDescriptors = [sortWpt]
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable CDWaypoints")
            
            // 从核心数据中检索点数组
            guard let waypointResults = asynchronousFetchResult.finalResult else { return }

            DispatchQueue.main.async {
                for result in waypointResults {
                    let objectID = result.objectID

                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { continue }
                    
                    let pt = GPXWaypoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    
                    pt.time = safePoint.time
                    pt.desc = safePoint.desc
                    pt.name = safePoint.name
                    if safePoint.elevation != .greatestFiniteMagnitude {
                        pt.elevation = safePoint.elevation
                    }

                    self.waypoints.append(pt)
                }
                self.waypointId = waypointResults.last?.waypointId ?? Int64()

                self.crashFileRecovery()
                print("Core Data Helper: fetched \(self.waypoints.count) CDWaypoints ")
                print("Core Data Helper: async fetches complete.")
            }
        }
        return asynchronousWaypointFetchRequest
    }
    
}

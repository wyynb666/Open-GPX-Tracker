//
//  CoreDataHelper.swift
//  OpenGpxTracker
//

import UIKit
import CoreData
import CoreGPX

// Core Data implementation
class CoreDataHelper {

    var waypointId = Int64()
    var trackpointId = Int64()
    var tracksegmentId = Int64()
    var isContinued = false
    var lastTracksegmentId = Int64()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var tracksegments = [GPXTrackSegment]()
    var currentSegment = GPXTrackSegment()
    var waypoints = [GPXWaypoint]()
    var lastFileName = String()

    // 最新的文件添加到Core Data
    func add(toCoreData lastFileName: String, willContinueAfterSave willContinue: Bool) {

        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // 建立连接
        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            let root = NSEntityDescription.insertNewObject(forEntityName: "CDRoot", into: childManagedObjectContext) as! CDRoot
            root.lastFileName = lastFileName
            root.continuedAfterSave = willContinue
            root.lastTrackSegmentId = self.tracksegmentId
            
            do {
                try childManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding last file name: \(error)")
                    }
                }
            } catch {
                print("Failure to save child context when adding last file name: \(error)")
            }
        }
    }
    
    // Add a trackpoint to Core Data
    func add(toCoreData trackpoint: GPXTrackPoint, withTrackSegmentID Id: Int) {
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            print("Core Data Helper: Add trackpoint with id: \(self.trackpointId)")

            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDTrackpoint", into: childManagedObjectContext) as! CDTrackpoint
            
            guard let elevation = trackpoint.elevation else { return }
            guard let latitude = trackpoint.latitude   else { return }
            guard let longitude = trackpoint.longitude else { return }
            
            pt.elevation = elevation
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = trackpoint.time
            pt.trackpointId = self.trackpointId
            pt.trackSegmentId = Int64(Id)

            do {
                let serialized = try JSONEncoder().encode(trackpoint)
                pt.serialized = serialized
            } catch {
                print("Core Data Helper: serialization error when adding trackpoint: \(error)")
            }
            
            self.trackpointId += 1
            
            do {
                try childManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding trackpoint: \(error)")
                    }
                }
            } catch {
                print("Failure to save child context when adding trackpoint: \(error)")
            }
        }
    }
    
    // Adds a waypoint to Core Data
    func add(toCoreData waypoint: GPXWaypoint) {
        let waypointChildManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Creates the link between child and parent
        waypointChildManagedObjectContext.parent = appDelegate.managedObjectContext
        
        waypointChildManagedObjectContext.perform {
            print("Core Data Helper: Add waypoint with id: \(self.waypointId)")
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDWaypoint", into: waypointChildManagedObjectContext) as! CDWaypoint
            guard let latitude = waypoint.latitude   else { return }
            guard let longitude = waypoint.longitude else { return }
            
            if let elevation = waypoint.elevation {
                pt.elevation = elevation
            } else {
                pt.elevation = .greatestFiniteMagnitude
            }
            
            pt.name = waypoint.name
            pt.desc = waypoint.desc
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = waypoint.time
            pt.waypointId = self.waypointId
            
            // 序列化trackpoint
            do {
                let serialized = try JSONEncoder().encode(waypoint)
                pt.serialized = serialized
            } catch {
                print("Core Data Helper: serialization error when adding waypoint: \(error)")
            }
            
            self.waypointId += 1
            
            do {
                try waypointChildManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding waypoint: \(error)")
                    }
                }
            } catch {
                print("Failure to save parent context when adding waypoint: \(error)")
            }
        }
    }

    /// Updates a previously added waypoint to Core Data
    func update(toCoreData updatedWaypoint: GPXWaypoint, from index: Int) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let wptFetchRequest = NSFetchRequest<CDWaypoint>(entityName: "CDWaypoint")
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: updating waypoint in Core Data")
            
            // 从Core Data中检索点数组
            guard let waypointResults = asynchronousFetchResult.finalResult else { return }
            
            privateManagedObjectContext.perform {
                let objectID = waypointResults[index].objectID
                guard let pt = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { return }
                
                guard let latitude = updatedWaypoint.latitude   else { return }
                guard let longitude = updatedWaypoint.longitude else { return }
                
                if let elevation = updatedWaypoint.elevation {
                    pt.elevation = elevation
                } else {
                    pt.elevation = .greatestFiniteMagnitude
                }
                
                pt.name = updatedWaypoint.name
                pt.desc = updatedWaypoint.desc
                pt.latitude = latitude
                pt.longitude = longitude
                
                do {
                    try privateManagedObjectContext.save()
                    self.appDelegate.managedObjectContext.performAndWait {
                        do {
                            try self.appDelegate.managedObjectContext.save()
                        } catch {
                            print("Failure to update and save waypoint to parent context: \(error)")
                        }
                    }
                } catch {
                    print("Failure to update and save waypoint to context at child context: \(error)")
                }
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch {
            print("NSAsynchronousFetchRequest (for finding updatable waypoint) error: \(error)")
        }
    }

    // Retrieves everything from Core Data
    func retrieveFromCoreData() {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        
        do {
            try privateManagedObjectContext.execute(rootFetchRequest())
            try privateManagedObjectContext.execute(trackPointFetchRequest())
            try privateManagedObjectContext.execute(waypointFetchRequest())
        } catch let error {
            print("NSAsynchronousFetchRequest (fetch request for recovery) error: \(error)")
        }
    }

    /// Delete Waypoint from index
    func deleteWaypoint(fromCoreDataAt index: Int) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let wptFetchRequest = NSFetchRequest<CDWaypoint>(entityName: "CDWaypoint")
        wptFetchRequest.includesPropertyValues = false
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: delete waypoint from Core Data at index: \(index)")

            guard let waypointResults = asynchronousFetchResult.finalResult else { return }
            
            privateManagedObjectContext.delete(waypointResults[index])
            
            do {
                try privateManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context (when deleting waypoint): \(error)")
                    }
                }
            } catch {
                print("Failure to save context at child context (when deleting waypoint): \(error)")
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (for finding deletable waypoint) error: \(error)")
        }
        
    }

    /// Delete all objects of entity given as parameter in Core Data.
    func coreDataDeleteAll<T: NSManagedObject>(of type: T.Type) {
        print("Core Data Helper: Batch Delete \(T.self) from Core Data")

        if #available(iOS 10.0, *) {
            modernBatchDelete(of: T.self)
        } else {
            legacyBatchDelete(of: T.self)
        }
    }

    // 提示用户如何处理恢复的数据
    func crashFileRecovery() {
        DispatchQueue.global().async {
            // 检查trackpoint和waypoint是否可用
            if self.currentSegment.points.count > 0 || self.waypoints.count > 0 {
                let root: GPXRoot
                let track = GPXTrack()

                // 加载文件
                if self.lastFileName != "" {
                    let gpx = GPXFileManager.URLForFilename(self.lastFileName)
                    let parsedRoot = GPXParser(withURL: gpx)?.parsedData()
                    root = parsedRoot ?? GPXRoot(creator: kGPXCreatorString)
                } else {
                    root = GPXRoot(creator: kGPXCreatorString)
                }
                // 从恢复的数据中生成一个GPXRoot
                if self.isContinued && self.tracksegments.count >= (self.lastTracksegmentId + 1) {
                    
                    // 检查是否存在轨道段
                    if root.tracks.last?.segments.count == 0 {
                        root.tracks.last?.add(trackSegment: GPXTrackSegment())
                    }
                    root.tracks.last?.segments[Int(self.lastTracksegmentId)].add(trackpoints: self.tracksegments.first!.points)
                    self.tracksegments.remove(at: 0)                    
                } else {
                    track.segments = self.tracksegments
                    root.add(track: track)
                }
                root.waypoints = self.waypoints

                DispatchQueue.main.sync {
                    NotificationCenter.default.post(name: .loadRecoveredFile, object: nil,
                                                    userInfo: ["recoveredRoot": root, "fileName": self.lastFileName])
                    let toastMessage = NSLocalizedString("LAST_SESSION_LOADED",
                                                         comment: "the filename displayed after the text") + " \n" + self.lastFileName + ".gpx"
                    Toast.regular(toastMessage, position: .top)
                }
            } else {
            }
        }
    }
    
    // 将恢复的数据保存到GPX文件，无需在地图上加载
    func saveFile(from gpx: GPXRoot, andIfAvailable lastfileName: String) {
        // date format same as usual.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
        var fileName = String()
        
        if lastfileName != "" {
            fileName = lastfileName
        } else if let lastTrkptDate = gpx.tracks.last?.segments.last?.points.last?.time {
            fileName = dateFormatter.string(from: lastTrkptDate)
        } else {
            fileName = dateFormatter.string(from: Date())
        }
        
        let recoveredFileName = "recovery-\(fileName)"
        let gpxString = gpx.gpx()
        
        // Save the recovered file
        GPXFileManager.save(recoveredFileName, gpxContents: gpxString)
        print("File \(recoveredFileName) was recovered from previous session, prior to unexpected crash/exit")
        
        // clear aft save
        self.clearAll()
        self.coreDataDeleteAll(of: CDRoot.self)
    }

    // Resets trackpoints and waypoints Id
    func resetIds() {
        self.trackpointId = 0
        self.waypointId = 0
        self.tracksegmentId = 0
    }
    
    // Clear all arrays and current segment after recovery.
    func clearObjects() {
        self.tracksegments = []
        self.waypoints = []
        self.currentSegment = GPXTrackSegment()
    }
    
    func clearAllExceptWaypoints() {
        self.coreDataDeleteAll(of: CDTrackpoint.self)

        self.tracksegments = []

        self.currentSegment = GPXTrackSegment()

        self.trackpointId = 0
        self.tracksegmentId = 0
    }
    
    // clears all
    func clearAll() {
        self.coreDataDeleteAll(of: CDTrackpoint.self)
        self.coreDataDeleteAll(of: CDWaypoint.self)

        self.clearObjects()

        self.currentSegment = GPXTrackSegment()

        self.resetIds()
    }
}

//
//  CoreDataHelper+BatchDelete.swift
//  OpenGpxTracker
//

import CoreData

extension CoreDataHelper {
    
    @available(iOS 10.0, *)
    func modernBatchDelete<T: NSManagedObject>(of type: T.Type) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        
        privateManagedObjectContext.perform {
            do {
                let name = "\(T.self)"
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                // execute delete request
                try privateManagedObjectContext.execute(deleteRequest)
                
                try privateManagedObjectContext.save()
                
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // 将更改从子项保存到应用的上下文
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context after delete: \(error)")
                    }
                }
            } catch {
                print("Failed to delete all from core data, error: \(error)")
            }
        }
    }
    
    func legacyBatchDelete<T: NSManagedObject>(of type: T.Type) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates fetch request
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.includesPropertyValues = false
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { asynchronousFetchResult in
            
            // 从核心数据中检索点数组
            guard let results = asynchronousFetchResult.finalResult else { return }
            
            for result in results {
                privateManagedObjectContext.delete(result)
            }
            
            do {
                try privateManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // 将更改从子项保存到应用的上下文
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context: \(error)")
                    }
                }
            } catch {
                print("Failure to save context at child context: \(error)")
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (while deleting \(T.self) error: \(error)")
        }
    }
}

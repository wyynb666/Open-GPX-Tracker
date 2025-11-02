//
//  AppDelegate.swift
//  OpenGpxTracker
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Default function
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // 当应用程序即将从活动状态变为非活动状态时发送
        // 或者当用户退出应用程序进入到后台状态
        // 使用此方法可以暂停正在进行的任务、禁用计时器以及降低 OpenGL ES 帧速率
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 释放共享资源、保存用户数据、使计时器失效并存储足够的应用程序状态信息
        // 以将应用程序还原到当前状态，以防稍后终止。
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // 作为从后台到非活动状态转换的一部分进行调用
        // 在这里，可以撤消进入后台时所做的许多更改
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                print("AppDelegate:: WCSession is supported")
                let session = WCSession.default
                session.delegate = self
                session.activate()
                print("AppDelegate:: WCSession activated")
            } else {
                print("AppDelegate:: WCSession is not supported")
            }
        }
        // 重新启动应用程序处于非活动状态时暂停的任何任务
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // 当应用程序即将终止时调用 保存数据
        // 在应用程序终止之前保存应用程序托管对象上下文中的更改
        // self.saveContext()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("load gpx File: \(url.absoluteString)")
        let fileManager = FileManager.default
        do {
            _ = url.startAccessingSecurityScopedResource()
            try fileManager.copyItem(at: url, to: GPXFileManager.GPXFilesFolderURL.appendingPathComponent(url.lastPathComponent))
            url.stopAccessingSecurityScopedResource()
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        // 收到文件时发布通知
        NotificationCenter.default.post(name: .didReceiveFileFromURL, object: nil)
        
        return true
    }

    lazy var applicationDocumentsDirectory: URL = {
        // 应用程序用于存储核心数据存储文件的目录
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
        }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "OpenGpxTracker", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // 创建持久化存储协调器并添加持久化存储
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("open-gpx-tracker-session.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url,
                                               options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                         NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)

            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

// 处理从 Apple Watch 配套应用程序传输的文件
@available(iOS 9.0, *)
extension AppDelegate: WCSessionDelegate {
    
    // 当WCSession变为非活动状态时调用
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("AppDelegate:: WCSession has become inactive")
    }
    
    // 当WCSession处于非活动状态时调用
    func sessionDidDeactivate(_ session: WCSession) {
        print("AppDelegate:: WCSession has deactivated")
    }

    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("AppDelegate:: activationDidCompleteWithActivationState: WCSession activated")
        case .inactive:
            print("AppDelegate:: activationDidCompleteWithActivationState: WCSession inactive")
        case .notActivated:
            print("AppDelegate:: activationDidCompleteWithActivationState: WCSession not activated, error:\(String(describing: error))")
            
        default: break
        }
    }
    
    // 从Apple Watch收到文件
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // swiftlint:disable:next force_cast
        let fileName = file.metadata!["fileName"] as! String?
        DispatchQueue.global().sync {
            GPXFileManager.moveFrom(file.fileURL, fileName: fileName)
            print("ViewController:: Received file from WatchConnectivity Session")
        }
        
        // 从Apple Watch收到文件的通知
        NotificationCenter.default.post(name: .didReceiveFileFromAppleWatch, object: nil, userInfo: ["fileName": fileName ?? ""])
    }
}

/// 从外部源接收文件的通知
extension Notification.Name {
    
    /// Use when a file is received from external source.
    static let didReceiveFileFromURL = Notification.Name("didReceiveFileFromURL")
    
    /// Use when a file is received from Apple Watch.
    static let didReceiveFileFromAppleWatch = Notification.Name("didReceiveFileFromAppleWatch")
}

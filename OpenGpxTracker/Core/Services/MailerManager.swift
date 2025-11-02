//
//  MailerManager.swift
//  OpenGpxTracker
//

import Foundation
import UIKit
import MessageUI

class MailerManager: NSObject, MFMailComposeViewControllerDelegate {
    
    var composer: MFMailComposeViewController!
    var controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
        super.init()
    }
    
    func send(filepath: String) {
        
        composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        // 设置主题
        composer.setSubject("[Open GPX tracker] Gpx File")
        var body = "Open GPX Tracker \n is an open source app for Apple devices. Create GPS tracks and export them to GPX files."
        composer.setMessageBody(body, isHTML: true)
        let fileData: NSData = NSData.dataWithContentsOfFile(filepath, options: .DataReadingMappedIfSafe, error: nil)
        composer.addAttachmentData(fileData, mimeType: "application/gpx+xml", fileName: filepath.lastPathComponent)
    
        // 显示comopser视图控制器
        controller.presentViewController(composer, animated: true, completion: nil)
    
    }

    func mailComposeController(controller: MFMailComposeViewController!,
                               didFinishWithResult result: MFMailComposeResult,
                               error: NSError!) {
            switch result.value {
            case MFMailComposeResultSent.value:
                println("Email sent")
            default:
                println("Whoops")
            }
            
            controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

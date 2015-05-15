//
//  DragUploadManager.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/13/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire
import AFNetworking

class DragUploadManager: NSObject, NSUserNotificationCenterDelegate {
    let dropHandlers: [DropHandler] = [FilenameDropHandler(), FilenamesDropHandler()]
    var notificationCenter: NSUserNotificationCenter {
        get {
            return NSUserNotificationCenter.defaultUserNotificationCenter()
        }
    }
    
    override init() {
        super.init()
        self.notificationCenter.delegate = self
    }

    func performDrop(drag: NSDraggingInfo, onComplete: (() -> Void)?) -> Bool {
        var pasteboard = drag.draggingPasteboard()
        var dropHandler: DropHandler?
        
        // find appropriate DropHandler
        for handler in self.dropHandlers {
            if handler.canHandlePasteboard(pasteboard) {
                dropHandler = handler
                break
            }
        }
        
        if dropHandler != nil {
            // start upload
            dropHandler!.performUpload(pasteboard, onComplete: { (url) -> Void in
                self.copyLinkToPasteboard(url)
                
                if onComplete != nil {
                    onComplete!()
                }
            })
            return true
        }
        
        return false
    }
    
    func copyLinkToPasteboard(link: NSURL) {
        let pb = NSPasteboard.generalPasteboard()
        pb.clearContents()
        pb.writeObjects([link])
        
        let notification = NSUserNotification()
        notification.title = "Uploaded!"
        notification.informativeText = "\(link) has been copied to your clipboard."
        notification.userInfo = ["url": link.absoluteString!]
        
        self.notificationCenter.deliverNotification(notification)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        if let url = notification.userInfo?["url"] as? String {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
        }
    }
}
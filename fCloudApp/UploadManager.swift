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

class UploadManager: NSObject, NSUserNotificationCenterDelegate {
    let uploadHandlers: [UploadHandler] = [FilenameUploadHandler(), FilenamesUploadHandler()]
    let screenshotDetector = ScreenshotDetector()
    var onUploadBegin: (() -> Void)?
    var onUploadComplete: (() -> Void)?
    
    var notificationCenter: NSUserNotificationCenter {
        get {
            return NSUserNotificationCenter.defaultUserNotificationCenter()
        }
    }
    
    override init() {
        super.init()
        self.notificationCenter.delegate = self
        self.screenshotDetector.onScreenshotTaken = self.onScreenshotTaken
    }

    func performDrop(drag: NSDraggingInfo) -> Bool {
        var pasteboard = drag.draggingPasteboard()
        var uploadHandler: UploadHandler?
        
        // find appropriate UploadHandler
        for handler in self.uploadHandlers {
            if handler.canHandlePasteboard(pasteboard) {
                uploadHandler = handler
                break
            }
        }
        
        if uploadHandler != nil {
            // start upload
            if let callback = self.onUploadBegin {
                callback()
            }
            uploadHandler!.performUpload(pasteboard, onComplete: self.uploadHandlerDidFinish)
            return true
        }
        
        return false
    }
    
    func onScreenshotTaken(paths: [String]) {
        var uploadHandler: UploadHandler?
        
        // find appropriate UploadHandler
        for handler in self.uploadHandlers {
            if handler.canHandleFiles(paths) {
                uploadHandler = handler
                break
            }
        }
        
        if uploadHandler != nil {
            // start upload
            if let callback = self.onUploadBegin {
                callback()
            }
            
            uploadHandler!.performUpload(paths, onComplete: self.uploadHandlerDidFinish)
        }
    }
    
    func uploadHandlerDidFinish(url: NSURL) {
        self.copyLinkToPasteboard(url)
        if let callback = self.onUploadComplete {
            callback()
        }
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
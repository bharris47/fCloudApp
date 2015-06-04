//
//  DropItem.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/14/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire
import AFNetworking

protocol UploadHandler {
    func canHandlePasteboard(pasteboard: NSPasteboard) -> Bool
    
    func canHandleFiles(filenames: [String]) -> Bool

    func performUpload(pasteboard: NSPasteboard, onComplete: (url:NSURL) -> Void)
    
    func performUpload(filePaths: [String], onComplete: (url:NSURL) -> Void)
}

class FilenameUploadHandler: UploadHandler {
    func canHandlePasteboard(pasteboard: NSPasteboard) -> Bool {
        if let types = pasteboard.types as? [String] {
            if contains(types, NSFilenamesPboardType) {
                var filenames = pasteboard.propertyListForType(NSFilenamesPboardType) as! [String]
                return canHandleFiles(filenames)
            }
        }

        return false
    }

    func performUpload(pasteboard: NSPasteboard, onComplete: (url:NSURL) -> Void) {
        var filePath = self.value(pasteboard) as! String
        self.performUpload([filePath], onComplete: onComplete)
    }
    
    func performUpload(filePaths: [String], onComplete: (url:NSURL) -> Void) {
        var filePath = filePaths[0]
        
        let request = Imgur.imageMultipartRequest({
            (data: AFMultipartFormData!) in
            data.appendPartWithFileURL(NSURL(fileURLWithPath: filePath), name: "image", error: nil)
        })
        
        Alamofire.request(request).responseJSON(options: nil, completionHandler: {
            (_, _, response, _) -> Void in
            println(response)
            if let json = response as? NSDictionary {
                if let link = (json["data"] as! NSDictionary)["link"] as? String {
                    onComplete(url: NSURL(string: link)!)
                }
            }
        })
    }

    func canHandleFiles(filenames: [String]) -> Bool {
        return count(filenames) == 1
    }
    
    func value(pasteboard: NSPasteboard) -> AnyObject {
        return (pasteboard.propertyListForType(NSFilenamesPboardType) as! [String])[0]
    }
}

class FilenamesUploadHandler: FilenameUploadHandler {
    typealias DropType = [String]

    override func performUpload(pasteboard: NSPasteboard, onComplete: (url:NSURL) -> Void) {
        var filePaths = self.value(pasteboard) as! [String]
        self.performUpload(filePaths, onComplete: onComplete)
    }
    
    override func performUpload(filePaths: [String], onComplete: (url:NSURL) -> Void) {
        // Create album
        Alamofire.request(Imgur.albumRequest()).responseJSON(options: nil) { (_, _, response, _) -> Void in
            println(response)
            if let data = ((response as! NSDictionary)["data"] as? [String: String]) {
                let albumId = data["id"]!
                let deleteHash = data["deletehash"]!
                
                // Add images to album using deletehash
                var imageCount = count(filePaths)
                for path in filePaths {
                    let request = Imgur.imageMultipartRequest(["album": deleteHash], bodyBuilder: {
                        (data: AFMultipartFormData!) in
                        data.appendPartWithFileURL(NSURL(fileURLWithPath: path), name: "image", error: nil)
                        }
                    )
                    
                    Alamofire.request(request).responseJSON(options: nil, completionHandler: { (_, _, response, _) -> Void in
                        println(response)
                        imageCount -= 1
                        if imageCount == 0 {
                            onComplete(url: NSURL(string: Imgur.urlForAlbum(albumId))!)
                        }
                    })
                }
            }
        }
    }

    override func canHandleFiles(filenames: [String]) -> Bool {
        return count(filenames) > 1
    }
    
    override func value(pasteboard: NSPasteboard) -> AnyObject {
        return pasteboard.propertyListForType(NSFilenamesPboardType) as! [String]
    }
}
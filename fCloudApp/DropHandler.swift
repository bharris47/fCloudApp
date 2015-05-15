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

protocol DropHandler {
    func canHandlePasteboard(pasteboard: NSPasteboard) -> Bool

    func performUpload(pasteboard: NSPasteboard, onComplete: (url:NSURL) -> Void)
}

class FilenameDropHandler: DropHandler {
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
        
        let request = Imgur.imageMultipartRequest({
            (data: AFMultipartFormData!) in
            data.appendPartWithFileURL(NSURL(fileURLWithPath: filePath), name: "image", error: nil)
        })

        Alamofire.request(request).responseJSON(options: nil, completionHandler: {
            (_, _, response, _) -> Void in
            if let link = ((response! as? NSDictionary)?["data"] as? [String:String])?["link"] {
                onComplete(url: NSURL(string: link)!)
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

class FilenamesDropHandler: FilenameDropHandler {
    typealias DropType = [String]

    override func performUpload(pasteboard: NSPasteboard, onComplete: (url:NSURL) -> Void) {
        var filePaths = self.value(pasteboard) as! [String]
        
        // Create album
        Alamofire.request(Imgur.albumRequest()).responseJSON(options: nil) { (_, _, response, _) -> Void in
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
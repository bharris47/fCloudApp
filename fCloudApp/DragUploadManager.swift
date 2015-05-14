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

protocol DragUploadCallback {
    func dragUploadDidBegin()
    func dragUploadDidComplete()
}

class DragUploadManager {
    var callback: DragUploadCallback?
    
    init(callback: DragUploadCallback?) {
        self.callback = callback
    }
    
    func performDrop(drag: NSDraggingInfo) -> Bool {
        var pboard = drag.draggingPasteboard()
        if let types = pboard.types as? [String] {
            if contains(types, NSFilenamesPboardType) {
                self.filesDropped(pboard.propertyListForType(NSFilenamesPboardType) as! [String])
                return true
            } else if contains(types, NSTIFFPboardType) {
                if let image = NSImage(data: pboard.dataForType(NSTIFFPboardType)!) {
                    self.imageDropped(image)
                    return true
                }
            }
        }
        
        return false
    }
    
    func filesDropped(filePaths: [String]) {
        self.upload(filePaths[0])
    }
    
    func imageDropped(image: NSImage) {
    }
     
    func upload(filePath: String) {
        println(filePath)
        
        let serializer = AFHTTPRequestSerializer()
        let url = "https://api.imgur.com/3/image"
        let fileUrl = NSURL(fileURLWithPath: filePath)
        
        let request = serializer.multipartFormRequestWithMethod(
            "POST",
            URLString: url,
            parameters: nil,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                data.appendPartWithFileURL(fileUrl, name: "image", error: nil)
            },
            error: nil
        )
        
        request.addValue("Client-ID " + ImgurCredentials.clientId, forHTTPHeaderField: "Authorization")
        
        self.callback?.dragUploadDidBegin()
        Alamofire.request(request).responseJSON(options: nil, completionHandler: { (_, _, response, _) -> Void in
            if let json = response! as? NSDictionary {
                if let data = json["data"] as? NSDictionary {
                    if let link = data["link"] as? String {
                        println(link)
                        let pb = NSPasteboard.generalPasteboard()
                        pb.clearContents()
                        pb.setString(link, forType: NSPasteboardTypeString)
                    }
                }
            }
            
            self.callback?.dragUploadDidComplete()
        })
    }
}
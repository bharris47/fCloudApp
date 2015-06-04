//
//  ScreenshotDetector.swift
//  fCloudApp
//
//  Created by Ben Harris on 6/3/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation

class ScreenshotDetector: NSObject {
    let query = NSMetadataQuery()
    var onScreenshotTaken: ((paths: [String]) -> Void)?
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "queryUpdated:",
            name: NSMetadataQueryDidUpdateNotification,
            object: self.query
        )
        
        self.query.predicate = NSPredicate(fromMetadataQueryString: "kMDItemIsScreenCapture = 1")
        self.query.startQuery()
    }
    
    func queryUpdated(notification: NSNotification) {
        var items = notification.userInfo?[NSMetadataQueryUpdateAddedItemsKey] as! [NSMetadataItem]
        
        if count(items) > 0 {
            if let callback = self.onScreenshotTaken {
                let screenshots = items.map {
                    (var item) -> String in
                    return item.valueForAttribute(NSMetadataItemPathKey) as! String
                }
                
                callback(paths: screenshots)
            }
        }
    }
}
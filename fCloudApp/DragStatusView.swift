//
//  DragStatusView.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/11/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import Cocoa

class DragStatusView : NSView, DragUploadCallback {
    var imageView: NSImageView!
    var dragManager: DragUploadManager!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.imageView = NSImageView(frame: self.bounds)
        self.imageView.unregisterDraggedTypes()
        self.imageView.image = NSImage(named: "fCloudApp")
        self.addSubview(self.imageView)
        
        self.dragManager = DragUploadManager(callback: self)
        self.registerForDraggedTypes([NSFilenamesPboardType, NSTIFFPboardType])
    }
   
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        return self.dragManager.performDrop(sender)
    }
    
    func dragUploadDidBegin() {
        
    }
    
    func dragUploadDidComplete() {
        
    }
}

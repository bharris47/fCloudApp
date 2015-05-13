//
//  DragStatusView.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/11/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import Cocoa

class DragStatusView :NSImageView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        var pboard = sender.draggingPasteboard()
        if contains(pboard.types! as [String], NSFilenamesPboardType) {
            println(pboard.propertyListForType(NSFilenamesPboardType))
        }
        return false
    }
}

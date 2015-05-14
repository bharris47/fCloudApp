//
//  DragManager.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/13/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import Cocoa

class DragManager {
    func performDrop(drag: NSDraggingInfo) -> Bool {
        var pboard = drag.draggingPasteboard()
        if let types = pboard.types as? [String] {
            if contains(types, NSFilenamesPboardType) {
                self.filesDropped(pboard.propertyListForType(NSFilenamesPboardType) as [String])
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
        
    }
    
    func imageDropped(image: NSImage) {
        
    }
}
//
//  DragStatusView.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/11/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import Cocoa

class DragStatusView: NSView {
    let dragTypes = [NSFilenamesPboardType, NSTIFFPboardType]
    var imageView: NSImageView!
    var dragManager: DragUploadManager!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.imageView = NSImageView(frame: self.bounds)
        self.imageView.wantsLayer = true
        self.imageView.unregisterDraggedTypes()
        self.imageView.image = NSImage(named: "fCloudApp_dark")
        self.addSubview(self.imageView)

        self.dragManager = DragUploadManager()
        self.registerForDraggedTypes(self.dragTypes)
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }

    override func draggingExited(sender: NSDraggingInfo?) {

    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if self.dragManager.performDrop(sender, onComplete: uploadDidComplete) {
            self.imageView.unregisterDraggedTypes()
            beginAnimating()
            return true
        }
        
        return false
    }
    
    func beginAnimating() {
        var animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.6
        animation.toValue = 0.3
        animation.duration = 0.8
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.imageView.layer?.addAnimation(animation, forKey: "fade")
        
        self.imageView.image = NSImage(named:"fCloudApp")
    }
    
    func uploadDidComplete() {
        var animation = CABasicAnimation(keyPath: "opacity")
        animation.toValue = 1.0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.delegate = self
        self.imageView.layer?.addAnimation(animation, forKey: "fade")
        
        self.registerForDraggedTypes(self.dragTypes)
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        delay(3.0, closure: { () -> () in
            self.imageView.image = NSImage(named: "fCloudApp_dark")
        })
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

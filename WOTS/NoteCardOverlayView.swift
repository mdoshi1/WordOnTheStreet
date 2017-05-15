//
//  NoteCardOverlayView.swift
//  WOTS
//
//  Created by Max Freundlich on 4/29/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import Koloda
import Flurry_iOS_SDK

private let overlayRightImageName = "yesOverlayImage"
private let overlayLeftImageName = "noOverlayImage"

class NoteCardOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
                
                // Instrumentation: user swiped left
                Flurry.logEvent("NoteCard_Left")
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
                
                // Instrumentation: user swiped right
                Flurry.logEvent("NoteCard_Right")
            default:
                overlayImageView.image = nil
            }
        }
    }
    
}

//
//  UIView+Autolayout.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 4/29/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit

extension UIView {
    
    func usingAutolayout() -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
}

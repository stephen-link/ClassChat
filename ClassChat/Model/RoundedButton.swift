//
//  RoundedButton.swift
//  ClassChat
//
//  Created by Stephen Link on 8/5/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
    }

}

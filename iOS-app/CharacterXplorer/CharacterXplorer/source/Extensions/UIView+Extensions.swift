//
//  UIView+Extensions.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit

// MARK: - Rounding
extension UIView {
    
    func round(cornerRadius: CGFloat,
               borderWidth width: CGFloat = 0,
               borderColor color: UIColor = UIColor.clear)
    {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}

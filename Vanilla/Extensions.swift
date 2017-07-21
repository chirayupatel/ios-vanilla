//
//  Extensions.swift
//  Vanilla
//
//  Created by Alex on 7/16/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit

extension String {
    public func heightWithConstrainedWidth(_ width: CGFloat, for font: UIFont = UIFont.systemFont(ofSize: 12)) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}

//
//  UIInsetLabel.swift
//  OpenGpxTracker
//

import UIKit

class UIInsetLabel: UILabel {
    var insets = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom

        return size
    }

}

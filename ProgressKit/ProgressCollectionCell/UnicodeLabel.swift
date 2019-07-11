//
//  UnicodeLabel.swift
//  ProgressKit
//
//  Copyright © 2018 ProgressKit authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

open class UnicodeLabel: UILabel {
    
    var attributes = [NSAttributedString.Key: Any](){
        didSet{ setNeedsDisplay() }
    }
    
    open override var textColor: UIColor? {
        get {
            if attributes[.foregroundColor] == nil {
                attributes[.foregroundColor] = super.textColor
            }
            return attributes[.foregroundColor] as? UIColor
        }
        set {
            attributes[.foregroundColor] = newValue
        }
    }
    
    open override var shadowColor: UIColor? {
        get {
            guard let shadow = attributes[.shadow] as? NSShadow else {
                return super.shadowColor
            }
            return shadow.shadowColor as? UIColor ?? super.shadowColor
        }
        set {
            let shadow = attributes[.shadow] as? NSShadow ?? NSShadow()
            shadow.shadowColor = newValue
            attributes[.shadow] = shadow
        }
    }
    
    open override var shadowOffset: CGSize {
        get {
            guard let shadow = attributes[.shadow] as? NSShadow else {
                return super.shadowOffset
            }
            return shadow.shadowOffset
        }
        set {
            let shadow = attributes[.shadow] as? NSShadow ?? NSShadow()
            shadow.shadowOffset = newValue
            attributes[.shadow] = shadow
        }
    }
    
    open override func draw(_ rect: CGRect) {
        let textAttributes = attributes
        
        let unicodeShadow = NSShadow()
        unicodeShadow.shadowOffset = CGSize(width: 0, height: 0)
        unicodeShadow.shadowColor = UIColor.clear
        var unicodeAttributes: [NSAttributedString.Key: Any] = [
            .shadow: unicodeShadow
        ]
        if let textColor = textColor{
            unicodeAttributes[.foregroundColor] = textColor
        }
        
        let attributedString = NSMutableAttributedString(string: "")
        for unicodeScalar in (text ?? "").unicodeScalars {
            attributedString.append(NSAttributedString(
                string: String(unicodeScalar),
                attributes: unicodeScalar.isEmoji || unicodeScalar.isZeroWidthJoiner ? unicodeAttributes : textAttributes)
            )
        }
        attributedText = attributedString
        super.draw(rect)
    }
}


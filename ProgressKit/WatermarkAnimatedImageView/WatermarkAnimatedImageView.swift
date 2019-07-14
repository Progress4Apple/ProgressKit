//
//  WatermarkAnimatedImageView.swift
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
import FLAnimatedImage

/// Used by the notification extension to render the watermark above a GIPHY image.
public class WatermarkAnimatedImageView: FLAnimatedImageView {
    @IBOutlet public weak var watermarkImageView: UIImageView!
    
    public static func loadFromNib(bundle: Bundle = Bundle(for: WatermarkAnimatedImageView.self)) -> WatermarkAnimatedImageView {
        let nib = UINib(nibName: "WatermarkAnimatedImageView", bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? WatermarkAnimatedImageView else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }
}

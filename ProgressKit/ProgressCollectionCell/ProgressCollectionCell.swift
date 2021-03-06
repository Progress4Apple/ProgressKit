//
//  ProgressCollectionCell.swift
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

/**
 A `UICollectionViewCell` which is capable of drawing a progress bar based upon `PKStatus` and `PKReport`.
 */
@IBDesignable public class ProgressCollectionCell: UICollectionViewCell {
    @IBOutlet public weak var stackView: UIStackView!
    @IBOutlet public weak var leadingTitleLabel: UILabel!
    @IBOutlet public weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet public weak var trailingTitleLabel: UILabel!
    @IBOutlet public weak var leadingDetailLabel: UILabel!
    @IBOutlet public weak var trailingDetailLabel: UILabel!
    @IBOutlet public weak var progressView: UIProgressView!
    @IBOutlet public weak var progressViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet public weak var progressViewTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet public weak var progressViewCenterYConstraint: NSLayoutConstraint!
    
    public static let reuseIdentifier = "ProgressCollectionCell"
    public var representedId: String = ""
    
    public var isLoading = true {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.activityIndicator?.isHidden = !strongSelf.isLoading
                strongSelf.leadingTitleLabel?.isHidden = strongSelf.isLoading
                strongSelf.trailingTitleLabel?.isHidden = strongSelf.isLoading
                strongSelf.leadingDetailLabel?.isHidden = strongSelf.isLoading
                strongSelf.trailingDetailLabel?.isHidden = strongSelf.isLoading
                strongSelf.progressView?.isHidden = strongSelf.isLoading
                
                if strongSelf.isLoading {
                    strongSelf.activityIndicator?.startAnimating()
                } else {
                    strongSelf.activityIndicator?.stopAnimating()
                }
            }
        }
    }
    
    override public var tintColor: UIColor! {
        get { return super.tintColor }
        set {
            super.tintColor = newValue
            
            if #available(iOS 13.0, *) {
                progressView?.tintColor = newValue
                
                switch displayStyle {
                case .progress:
                    progressView?.progressTintColor = newValue
                    progressView?.trackTintColor = trackColor
                    
                    leadingDetailLabel?.textColor = newValue
                    trailingDetailLabel?.textColor = textColor
                    
                case .remaining:
                    progressView?.progressTintColor = trackColor
                    progressView?.trackTintColor = newValue
                    
                    leadingDetailLabel?.textColor = textColor
                    trailingDetailLabel?.textColor = newValue
                }
                
            } else {
                leadingTitleLabel?.textColor = newValue
                leadingTitleLabel?.shadowColor = tintShadowColor
                progressView?.tintColor = newValue
                
                switch displayStyle {
                case .progress:
                    progressView?.progressTintColor = newValue
                    progressView?.trackTintColor = trackColor
                    
                    leadingDetailLabel?.textColor = newValue
                    leadingDetailLabel?.shadowColor = tintShadowColor
                    trailingDetailLabel?.textColor = textColor
                    trailingDetailLabel?.shadowColor = nil
                    
                case .remaining:
                    progressView?.progressTintColor = trackColor
                    progressView?.trackTintColor = newValue
                    
                    leadingDetailLabel?.textColor = textColor
                    trailingDetailLabel?.textColor = newValue
                    trailingDetailLabel?.shadowColor = tintShadowColor
                }
            }
        }
    }
    
    @available(iOS, introduced: 12, deprecated, message: "Don't use this anymore")
    public var tintShadowColor: UIColor! {
        guard let tintColor = tintColor else { return nil }
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if tintColor.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r - 0.2, 0.0), green: max(g - 0.2, 0.0), blue: max(b - 0.2, 0.0), alpha: a)
        }
        return tintColor
    }
    
    public var displayStyle: PKDisplayStyle = .progress {
        didSet {
            switch displayStyle {
            case .progress:
                progressView?.progressTintColor = tintColor
                progressView?.trackTintColor = trackColor
                
                if #available(iOS 13.0, *) {
                    // no more shadows and colored labels on iOS 13 and above
                    leadingDetailLabel?.textColor = textColor
                } else {
                    leadingDetailLabel?.textColor = tintColor
                    leadingDetailLabel?.shadowColor = tintShadowColor
                }
                trailingDetailLabel?.textColor = textColor
                if #available(iOS 13.0, *) {
                    // no more shadows on iOS 13 and above
                } else {
                    trailingDetailLabel?.shadowColor = nil
                }
            
            case .remaining:
                progressView?.progressTintColor = trackColor
                progressView?.trackTintColor = tintColor
                
                leadingDetailLabel?.textColor = textColor
                if #available(iOS 13.0, *) {
                    // no more shadows on iOS 13 and above
                } else {
                    leadingDetailLabel?.shadowColor = nil
                }
                
                if #available(iOS 13.0, *) {
                    // no more shadows and colored labels on iOS 13 and above
                    trailingDetailLabel?.textColor = textColor
                } else {
                    trailingDetailLabel?.shadowColor = tintShadowColor
                    trailingDetailLabel?.textColor = tintColor
                }
            }
        }
    }
    
    public var layoutStyle: PKLayoutStyle = .table {
        didSet {
            switch layoutStyle {
            case .table: stackView?.axis = .horizontal
            case .grid: stackView?.axis = .vertical
            }
        }
    }
    
    // MARK: "@objc dynamic" adds UIAppearance support
    @objc dynamic public var borderWidth: CGFloat = 1.0 / UIScreen.main.scale {
        didSet { setNeedsDisplay() }
    }
    
    // MARK: "@objc dynamic" adds UIAppearance support
    @objc dynamic public var borderColor = UIColor(white: 0.3, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    // MARK: "@objc dynamic" adds UIAppearance support
    @objc dynamic public var trackColor: UIColor = UIColor(white: 0.3, alpha: 1.0) {
        didSet { progressView?.trackTintColor = trackColor }
    }
    
    // MARK: "@objc dynamic" adds UIAppearance support
    @objc dynamic public var textColor: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            }
            return UIColor.lightText
        }() {
        didSet {
            switch displayStyle {
            case .progress:
                if #available(iOS 13.0, *) {
                    // no more shadows on iOS 13 and above
                } else {
                    leadingTitleLabel?.shadowColor = tintShadowColor
                }
                trailingTitleLabel?.textColor = textColor
                if #available(iOS 13.0, *) {
                    // no more shadows on iOS 13 and above
                } else {
                    leadingDetailLabel?.shadowColor = tintShadowColor
                }
                trailingDetailLabel?.textColor = textColor
                
            case .remaining:
                if #available(iOS 13.0, *) {
                    // no more shadows on iOS 13 and above
                } else {
                    leadingTitleLabel?.shadowColor = tintShadowColor
                }
                trailingTitleLabel?.textColor = textColor
                leadingDetailLabel?.textColor = textColor
                if #available(iOS 13.0, *) {
                    // no more shadows on iOS 13 and above
                } else {
                    trailingDetailLabel?.shadowColor = tintShadowColor
                }
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        backgroundView = UIView()
        
        if #available(iOS 13.0, *) {
            // no more shadows and colored labels on iOS 13 and above
            leadingTitleLabel?.textColor = textColor
        } else {
            leadingTitleLabel?.textColor = tintColor
            leadingTitleLabel?.shadowColor = tintShadowColor
        }
        progressView?.progressTintColor = tintColor
        progressView?.trackTintColor = trackColor
    }
    
    
    public func configure(with status: PKStatus?, for report: PKReport) {
        isLoading = false
        
        if let color = status?.tintColor {
            tintColor = UIColor(cgColor: color)
        } else if let color = superview?.tintColor {
            tintColor = color
        }
        leadingTitleLabel?.text = status?.title
        
        displayStyle = report.displayStyle
        switch report.displayStyle {
        case .progress:
            if let status = status {
                trailingTitleLabel?.text = String(status.completed)
                
                leadingDetailLabel?.text = String(Int(status.completedPercentage * 100)) + "%"
                progressView?.progress = Float(status.completedPercentage)
                trailingDetailLabel?.text = String(status.goal)
            } else {
                trailingTitleLabel?.text = "0"
                
                leadingDetailLabel?.text = "0%"
                progressView?.progress = 0
                trailingDetailLabel?.text = "0"
            }
            
        case .remaining:
            if let status = status {
                trailingTitleLabel?.text = String(status.remaining)
                leadingDetailLabel?.text = String(status.goal)
                
                progressView?.progress = Float(status.completedPercentage)
                trailingDetailLabel?.text = String(Int(status.remainingPercentage * 100)) + "%"
            } else {
                trailingTitleLabel?.text = "0"
                leadingDetailLabel?.text = "0"
                
                progressView?.progress = 0
                trailingDetailLabel?.text = "0%"
            }
        }
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        representedId = ""
        
        leadingTitleLabel?.text = nil
        trailingTitleLabel?.text = nil
        leadingDetailLabel?.text = nil
        trailingDetailLabel?.text = nil
        
        progressView?.progress = 0
        
        isLoading = true
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        switch layoutStyle {
        case .table:
            stackView?.spacing = 0
            progressViewHeightConstraint?.constant = 2
            progressViewCenterYConstraint?.constant = 4
            progressViewTopMarginConstraint?.constant = 4
            
        case .grid:
            if self.bounds.height > 200 {
                stackView?.spacing = 32
                progressViewHeightConstraint?.constant = 4
                progressViewCenterYConstraint?.constant = 72
                progressViewTopMarginConstraint?.constant = 32
            } else {
                stackView?.spacing = 24
                progressViewHeightConstraint?.constant = 4
                progressViewCenterYConstraint?.constant = 64
                progressViewTopMarginConstraint?.constant = 24
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // triggered by collectionView.collectionViewLayout.invalidateLayout()
        // so we have a chance to react to orientation changes and update the constraints
        setNeedsUpdateConstraints()
    }
    
    private var borderPath: UIBezierPath?
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        selectedBackgroundView?.backgroundColor = borderColor.withAlphaComponent(0.25)
        borderPath?.removeAllPoints()

        switch layoutStyle {
        case .table:
            borderPath = UIBezierPath()
            borderPath?.move(to: CGPoint(x: layoutMargins.left, y: rect.maxY - borderWidth))
            borderPath?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - borderWidth))

            if let trailingTitleLabel = trailingTitleLabel {
                trailingTitleLabel.textAlignment = .right
                trailingTitleLabel.font = trailingTitleLabel.font.withSize(24)
            }
            
            borderPath?.lineWidth = borderWidth;
            borderColor.set()
            borderPath?.stroke()

        case .grid:
            backgroundView?.backgroundColor = backgroundColor
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
            layer.cornerRadius = 12

            if let trailingTitleLabel = trailingTitleLabel {
                trailingTitleLabel.textAlignment = .center
                trailingTitleLabel.font = trailingTitleLabel.font.withSize(64)
            }
        }
    }
}

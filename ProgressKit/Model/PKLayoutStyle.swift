//
//  PKLayoutStyle.swift
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

/// Defines how the reports should be laid out.
public enum PKLayoutStyle {
    
    /// Layout reports as regular table view. Used on small screens.
    case table
    
    /// Layout reports as grid view. Used on medium to big screens.
    case grid
    
    public func itemSize(in collectionView: UICollectionView) -> CGSize {
        switch self {
        case .table:
            return CGSize(width: collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right, height: 72)
        
        case .grid:
            let contentViewWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right;
            
            var columns: CGFloat = 2
            if contentViewWidth > 1000 {
                columns = 3
            }
            let sizeWidth = (contentViewWidth - columns * (collectionViewEdgeInsets.left + collectionViewEdgeInsets.right)) / columns
            
            return CGSize(
                width: sizeWidth,
                height: sizeWidth / 16 * 9
            )
        }
    }
    
    public var collectionViewEdgeInsets: UIEdgeInsets {
        switch self {
        case .table:
            return UIEdgeInsets.zero
        case .grid:
            return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    
    public var collectionViewLineSpacing: CGFloat {
        switch self {
        case .table:
            return 0
        case .grid:
            return 12
        }
    }
}

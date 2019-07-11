//
//  ProgressCollection.swift
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
import EventKit
import NotificationCenter

open class ProgressCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    private (set) public var allReports: [[PKReport]] = []
    private (set) public var selectedReport: PKReport?
    
    public var dataSource: ProgressCollectionViewControllerDataSource?
    public var delegate: ProgressCollectionViewControllerDelegate?
    
    private var notificationToken: PKNotification.Token?
    
    public func layoutStyle(for traitCollection: UITraitCollection) -> PKLayoutStyle {
        return traitCollection.horizontalSizeClass == .regular ? .grid : .table
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent || isBeingDismissed else { return }
        notificationToken = nil // RELEASE notificationToken
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard collectionView.isUserInteractionEnabled, !isBeingDismissed, !isBeingPresented, !isMovingFromParent, !isMovingToParent else { return }
        
        collectionView.indexPathsForSelectedItems?.forEach{ [weak self] in
            self?.collectionView.deselectItem(at: $0, animated: animated)
        }
        selectedReport = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(
            nibName: "ProgressCollectionCell",
            bundle: Bundle(for: ProgressCollectionCell.self)
        ), forCellWithReuseIdentifier: ProgressCollectionCell.reuseIdentifier)
        
        collectionView.register(UINib(
            nibName: "ProgressCollectionSectionHeader",
            bundle: Bundle(for: ProgressCollectionSectionHeader.self)
        ), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
           withReuseIdentifier: ProgressCollectionSectionHeader.reuseIdentifier)
        
        // MARK: Is ViewController displayed in a Today-Widget?
        if false == self is NCWidgetProviding {
            
            // MARK: AVOID LOADING BACKGROUND VIEW IN TODAY-WIDGET
            let backgroundNib = UINib(
                nibName: "ProgressCollectionBackgroundView",
                bundle: Bundle(for: ProgressCollectionBackgroundView.self)
            )
            if let backgroundView = backgroundNib.instantiate(withOwner: self, options: nil).first as? ProgressCollectionBackgroundView {
                collectionView.backgroundView = backgroundView
            }
            
            // MARK: AVOID SETTING GESTURE RECOGNIZERS IN TODAY-WIDGET
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(gesture:)))
            longPressGestureRecognizer.delaysTouchesBegan = true
            // a minimum press duration smaller than the default (= 0.5) is needed,
            // otherwise the default long press recognizer of the UIViewController
            // may kick in and then we do not have any possibility to overwrite
            // the targetPositions for the item in horizontal trait of .compact.
            longPressGestureRecognizer.minimumPressDuration = 0.4
            collectionView.addGestureRecognizer(longPressGestureRecognizer)
        }
        
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        notificationToken = Progress.notifier.addObserver(for: .reminderStoreDidChange){ [weak self] _ in
            self?.reloadData()
        }
    }
    
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: gesture.view!)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)

        case .changed:
            var targetPosition = gesture.location(in: gesture.view!)
            if traitCollection.horizontalSizeClass == .compact {
                targetPosition.x = collectionView.bounds.midX
            }
            collectionView.updateInteractiveMovementTargetPosition(targetPosition)

        case .ended:
            collectionView.endInteractiveMovement()

        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    public func reloadData(completionHandler: ((Error?)->Void)? = nil) {
        allReports = []
        statusCache = [:]
        selectedReport = nil
        
        DispatchQueue.main.async {
            Progress.reminderStore.verifyAuthorization { [weak self] status, error in
                guard let strongSelf = self else {
                    completionHandler?(nil)
                    return
                }
                
                guard let authorizationStatus = status else {
                    if let error = error {
                        strongSelf.delegate?.progressCollection(strongSelf, handleError: error)
                    }
                    completionHandler?(error)
                    return
                }
                
                guard authorizationStatus == .authorized else {
                    strongSelf.delegate?.progressCollection(strongSelf, handleAuthorizationStatusNotSufficient: authorizationStatus)
                    completionHandler?(error)
                    return
                }
                
                strongSelf.dataSource?.progressCollection(strongSelf, loadReports: { [weak self] allReports, error in
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else {
                            completionHandler?(nil)
                            return
                        }
                        
                        if let error = error {
                            strongSelf.delegate?.progressCollection(strongSelf, handleError: error)
                            completionHandler?(error)
                            return
                        }
                        
                        guard let allReports = allReports else {
                            strongSelf.collectionView.reloadData()
                            completionHandler?(nil)
                            return
                        }
                        strongSelf.allReports = allReports
                        
                        strongSelf.collectionView.reloadData()
                        strongSelf.collectionView.backgroundView?.isHidden = false == self?.allReports.first?.isEmpty
                        completionHandler?(nil)
                    }
                })
            }
        }
    }
    
    // MARK: UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let report = allReports[indexPath.section][indexPath.item]
            asyncFetch(statusFor: report)
        }
    }
    
    private var dispatchGroupForStatusLoading = DispatchGroup()
    private var statusForReportIsLoading = [PKReport: Bool]()
    private var statusCache: [PKReport: PKStatus] = [:]
    
    func asyncFetch(statusFor report: PKReport, completionHandler: ((PKStatus?, Error?) -> Void)? = nil) {
        guard self.statusCache[report] == nil, statusForReportIsLoading[report] == nil else {
            completionHandler?(nil, nil)
            return
        }
        statusForReportIsLoading[report] = true
        
        if self is NCWidgetProviding {
            /*
             The ViewController is displayed as Today-Widget.
             To prevent OutOfMemory errors, we force fetching
             to be done synchronously. This gives the Today-Widget
             a chance to release memory before fetching the next report status.
            */
            dispatchGroupForStatusLoading.wait()
            dispatchGroupForStatusLoading.enter()
        }
        
        Progress.reminderStore.fetchStatus(for: report, in: Calendar.current){ [weak self] status, error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.statusCache[report] = status
            strongSelf.statusForReportIsLoading[report] = nil
            
            completionHandler?(status, error)
            
            if strongSelf is NCWidgetProviding {
                strongSelf.dispatchGroupForStatusLoading.leave()
            }
        }
    }
    
    
    // MARK: UITraitCollection
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if layoutStyle(for: newCollection) != layoutStyle(for: traitCollection) {
            collectionView.reloadData() // Reload cells to adopt the new style
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if layoutStyle(for: traitCollection) == .table {
            collectionView.collectionViewLayout.invalidateLayout() // Called to update the cell sizes to fit the new collection view width
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allReports.count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allReports[section].count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProgressCollectionSectionHeader.reuseIdentifier, for: indexPath) as! ProgressCollectionSectionHeader
        
        sectionHeader.layoutStyle = layoutStyle(for: traitCollection)
        sectionHeader.leadingTitleLabel?.text = nil
        sectionHeader.trailingTitleLabel?.text = nil
        
        if allReports.count > indexPath.section, let sectionItem = allReports[indexPath.section].first {
            if indexPath.section > 0,
                let prevSectionItem = allReports[indexPath.section - 1].first,
                prevSectionItem.displayStyle == sectionItem.displayStyle {
                // same displayStyle. we don't need to set any leadingTitleLabel.
                // but in this case, we shrink the height of the sectionHeader a bit.
                // see ´referenceSizeForHeaderInSection´ for more information.
            } else {
                sectionHeader.leadingTitleLabel?.text = (sectionItem.displayStyle == .progress ? NSLocalizedString("Progress", comment: "Progress") : NSLocalizedString("Remaining", comment: "Remaining")).localizedCapitalized
            }
            
            if let timeRange = sectionItem.timeRange {
                sectionHeader.trailingTitleLabel?.text = Calendar.current.string(from: timeRange)
            } else {
                sectionHeader.trailingTitleLabel?.text = NSLocalizedString("Overall", comment: "overall").localizedCapitalized
            }
        }
        
        return sectionHeader
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let sectionItem = allReports[section].first,
            section > 0,
            let prevSectionItem = allReports[section - 1].first,
            prevSectionItem.displayStyle == sectionItem.displayStyle {
            // same displayStyle. we shrink the height of the sectionHeader,
            // to make this relationship more obvious.
            return CGSize(width: collectionView.frame.size.width, height: 28)
        }
        
        return CGSize(width: collectionView.frame.size.width, height: 46)
    }
    
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressCollectionCell.reuseIdentifier, for: indexPath) as! ProgressCollectionCell
        
        cell.tintColor = collectionView.tintColor
        cell.layoutStyle = layoutStyle(for: traitCollection)
        
        guard allReports.count > indexPath.section, allReports[indexPath.section].count > indexPath.row else {
            return cell
        }
        let report = allReports[indexPath.section][indexPath.row]
        cell.representedId = report.identifier
        
        if let status = statusCache[report] {
            cell.configure(with: status, for: report)
        
        } else {
            asyncFetch(statusFor: report){ [weak self] status, error in
                DispatchQueue.main.async {    
                    if let error = error {
                        if let strongSelf = self {
                            strongSelf.delegate?.progressCollection(strongSelf, handleError: error)
                        }
                        return
                    }
                    
                    guard cell.representedId == status?.reportIdentifier else {
                        return
                    }
                    cell.configure(with: status, for: report)
                }
            }
        }
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedReport = allReports[indexPath.section][indexPath.row]
        self.selectedReport = selectedReport
        delegate?.progressCollection(self, didSelectReport: selectedReport)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override open func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if originalIndexPath.section == proposedIndexPath.section {
            return proposedIndexPath
        }
        return originalIndexPath
    }
    
    override open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        /*
         You must implement this method to support the reordering of items
         within the collection view. If you do not implement this method, the
         collection view ignores any attempts to reorder items.
         
         When interactions with an item end, the collection view calls this
         method if the position of the item changed. Use this method to update
         your data structures with the new index path information.
        */
        
        let config = allReports[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        allReports[destinationIndexPath.section].insert(config, at: destinationIndexPath.item)
        
        dataSource?.progressCollection(self, saveReports: allReports){ [weak self] success, error in
            if let error = error, let strongSelf = self {
                delegate?.progressCollection(strongSelf, handleError: error)
            }
        }
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layoutStyle(for: traitCollection).itemSize(in: collectionView)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return layoutStyle(for: traitCollection).collectionViewEdgeInsets
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layoutStyle(for: traitCollection).collectionViewLineSpacing
    }
}

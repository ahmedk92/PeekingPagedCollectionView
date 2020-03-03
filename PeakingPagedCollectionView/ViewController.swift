//
//  ViewController.swift
//  PeakingPagedCollectionView
//
//  Created by Ahmed Khalaf on 3/3/20.
//  Copyright © 2020 io.github.ahmedkhalaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.decelerationRate = .fast
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.label.text = "\(indexPath.item)"
        cell.layer.cornerRadius = 8
        return cell
    }
    // MARK: - UICollectionViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let targetContentOffsetMiddleX = targetContentOffset.pointee.x + collectionView.bounds.width / 2
        let proposedIndex = Int(targetContentOffsetMiddleX / (cellSize.width + spacing / 4)).clamped(byMin: currentIndex - 1, max: currentIndex + 1).clamped(byMin: 0, max: count - 1)
        currentIndex = proposedIndex
        targetContentOffset.pointee.x = CGFloat(proposedIndex) * (cellSize.width + spacing / 4)
        
        // To fix choppiness on small quick swipes
        if velocity.x != 0 && lastTargetContentOffsetX == targetContentOffset.pointee.x {
            scrollView.setContentOffset(targetContentOffset.pointee, animated: true)
        }
        
        lastTargetContentOffsetX = targetContentOffset.pointee.x
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing / 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 4)
    }
    
    // MARK: - Private
    private var spacing: CGFloat {
        return 100
    }
    @IBOutlet private weak var collectionView: UICollectionView!
    private var cellSize: CGSize {
        return CGSize(width: collectionView.bounds.width - spacing, height: collectionView.bounds.height)
    }
    private var currentIndex = 0
    private var lastTargetContentOffsetX: CGFloat?
    private let count = 32
}

class Cell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

extension Numeric where Self: Comparable {
    func clamped(byMin min: Self, max: Self) -> Self {
        return Swift.min(Swift.max(min, self), max)
    }
}

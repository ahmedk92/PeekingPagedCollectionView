//
//  ViewController.swift
//  PeekingPagedCollectionView
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        insets = (peek / 2).rounded()
    }
        
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.label.text = "\(indexPath.item)"
        return cell
    }
    // MARK: - UICollectionViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let proposedIndex = Int((targetContentOffset.pointee.x + cellSize.width / 2) / cellSize.width)
        currentIndex = proposedIndex.clamped(byMin: currentIndex - 1, max: currentIndex + 1)
        targetContentOffset.pointee.x = CGFloat(currentIndex) * cellSize.width
        
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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: insets, bottom: 0, right: insets)
    }
    
    // MARK: - Private
    private var insets: CGFloat = 0 {
        didSet {
            if insets != oldValue {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    private var spacing: CGFloat {
        return spacingStrategy.spacing(collectionViewWidth: collectionView.bounds.width).rounded()
    }
    private var peek: CGFloat {
        return spacing * 4 // not necessarily a multiple of spacing; can be anything (but should be greater than spacing).
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var cellSize: CGSize {
        return CGSize(width: collectionView.bounds.width - peek, height: collectionView.bounds.height)
    }
    private var currentIndex = 0
    private var lastTargetContentOffsetX: CGFloat?
    private let count = 32
}


private let spacingStrategy = SpacingStrategy.proportional(1/16)
//private let spacingStrategy = SpacingStrategy.fixed(50)

enum SpacingStrategy {
    case fixed(CGFloat)
    case proportional(CGFloat)
    
    func constrain(viewWidthAnchor: NSLayoutDimension, superviewWidthAnchor: NSLayoutDimension) -> NSLayoutConstraint {
        switch self {
        case .fixed(let constant):
            return viewWidthAnchor.constraint(equalTo: superviewWidthAnchor, constant: -constant)
        case .proportional(let multiplier):
            return viewWidthAnchor.constraint(equalTo: superviewWidthAnchor, multiplier: 1 - multiplier)
        }
    }
    
    func spacing(collectionViewWidth: CGFloat) -> CGFloat {
        switch self {
        case .fixed(let spacing):
            return spacing
        case .proportional(let factor):
            return collectionViewWidth * factor
        }
    }
}

class Cell: UICollectionViewCell {
    lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        return label
    }()
    private lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spacingStrategy.constrain(viewWidthAnchor: view.widthAnchor, superviewWidthAnchor: contentView.widthAnchor),
            view.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension Numeric where Self: Comparable {
    func clamped(byMin min: Self, max: Self) -> Self {
        return Swift.min(Swift.max(min, self), max)
    }
}

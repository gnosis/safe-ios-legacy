//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

class SeedPhraseView: BaseCustomView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    struct CellMetrics {
        var size: CGSize = CGSize(width: 88, height: 54)
        var hSpace: CGFloat = 11
        var vSpace: CGFloat = 10
        var columnCount: Int = 3

        mutating func calculate(basedOn container: UIView) {
            if columnCount == 0 { return }
            size.width = floor((container.frame.width - CGFloat(columnCount - 1) * hSpace) / CGFloat(columnCount))
        }

        func totalHeight(itemCount: Int) -> CGFloat {
            if itemCount == 0 || columnCount == 0 { return 0 }
            let rowCount = ceil(CGFloat(itemCount) / CGFloat(columnCount))
            return rowCount * size.height + (rowCount - 1) * vSpace
        }

    }

    weak var collectionView: UICollectionView!
    weak var collectionViewLayout: UICollectionViewFlowLayout!
    var heightConstraint: NSLayoutConstraint!
    var metrics = CellMetrics()

    var words: [SeedWord] = [] {
        didSet {
            didUpdateWords()
        }
    }

    func didUpdateWords() {
        assert(words.enumerated().allSatisfy { $0.element.index == $0.offset }, "Incorrect word index")
        update()
        collectionView.reloadData()
    }

    override func commonInit() {
        backgroundColor = ColorName.snowwhite.color

        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        let nib = UINib(nibName: "SeedWordCollectionViewCell", bundle: Bundle(for: SeedWordCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "SeedWordCollectionViewCell")

        collectionView.backgroundColor = ColorName.snowwhite.color
        collectionView.allowsSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(collectionView)
        wrapAroundView(collectionView)

        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout

        heightConstraint = heightAnchor.constraint(equalToConstant: 240) // this will be changed during update()
        heightConstraint.isActive = true
    }

    override func update() {
        metrics.calculate(basedOn: collectionView)

        heightConstraint.constant = metrics.totalHeight(itemCount: words.count)
        setNeedsUpdateConstraints()

        collectionViewLayout.itemSize = metrics.size
        collectionViewLayout.minimumInteritemSpacing = metrics.hSpace
        collectionViewLayout.minimumLineSpacing = metrics.vSpace
        collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < words.count else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeedWordCollectionViewCell",
                                                      for: indexPath) as! SeedWordCollectionViewCell
        cell.word = words[indexPath.item]
        return cell
    }

}

//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol InputSeedViewDelegate: class {

    func inputSeedView(_ inputSeedView: InputSeedView, didEnterWord word: SeedWord)

}

/// Displays words to enter in the puzzle
class InputSeedView: SeedPhraseView {

    weak var delegate: InputSeedViewDelegate?

    override func didUpdateWords() {
        update()
        collectionView.reloadData()
    }

    override func commonInit() {
        super.commonInit()
        backgroundColor = ColorName.transparent.color
        collectionView.backgroundColor = ColorName.transparent.color

        let nib = UINib(nibName: "SeedInputCollectionViewCell", bundle: Bundle(for: SeedInputCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "SeedInputCollectionViewCell")

        collectionView.allowsSelection = true

        metrics = CellMetrics(size: CGSize(width: 100, height: 50),
                              hSpace: 19,
                              vSpace: 20,
                              columnCount: 2)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < words.count else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeedInputCollectionViewCell",
                                                      for: indexPath) as! SeedInputCollectionViewCell
        cell.word = words[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < words.count, words[indexPath.item].style == .normal else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        words[indexPath.item].style = .entered
        delegate?.inputSeedView(self, didEnterWord: words[indexPath.item])
    }

}

//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// CollectionUIModel is a "two-dimensional array"-like data structure intended to use as a model for UITableView.
///
/// This structure provides get-only access to
/// section counts, item counts, sections and items.
/// The CollectionUIModel, in essence, is a collection of sections, and each section is a collection of items (models
/// for individual rows and items of a UITableView).
///
/// The only advantage over using raw arrays is convenience and safety:
///    - subscript access to sections and items through Int index, IndexPath index
///    - out of bounds index results in nil instead of "OutOfBound" runtime exception
///    - methods to get counts of items in sections or count of sections.
public struct CollectionUIModel<SectionType> where SectionType: Collection {

    private var sections: [SectionType]

    public init(_ sections: [SectionType] = []) {
        self.sections = sections
    }

    public subscript(index: Int) -> SectionType? {
        return isInBounds(section: index) ? sections[index] : nil
    }

    public subscript(section indexPath: IndexPath) -> SectionType? {
        return self[indexPath.section]
    }

    public subscript(_ sectionIndex: Int, _ itemIndex: Int) -> SectionType.Element? {
        guard isInBounds(section: sectionIndex, item: itemIndex), let section = self[sectionIndex] else { return nil }
        let collectionIndex = section.index(section.startIndex, offsetBy: itemIndex)
        return section[collectionIndex]
    }

    public subscript(index: IndexPath) -> SectionType.Element? {
        return self[index.section, index.row]
    }

    public func isInBounds(section: Int) -> Bool {
        return 0 <= section && section < sections.count
    }

    public func isInBounds(section: Int, item: Int) -> Bool {
        return isInBounds(section: section) && 0 <= item && item < sections[section].count
    }

    public var isEmpty: Bool {
        return sections.isEmpty
    }

    public var sectionCount: Int {
        return sections.count
    }

    public func itemCount(section: Int) -> Int {
        return self[section]?.count ?? NSNotFound
    }

    public func itemCount(indexPath: IndexPath) -> Int {
        return self[indexPath.section]?.count ?? NSNotFound
    }

}

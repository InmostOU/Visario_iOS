//
//  MeetingsLayout.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 18.08.2021.
//

import UIKit

final class MeetingsLayout: UICollectionViewFlowLayout {
    
    private let numberOfColumns = 2
    private var collectionViewHeight: CGFloat = 0
    
    private let columnSpacing: CGFloat = 6
    var rowSpacing: CGFloat = 6
    
    private var layoutAttributesСache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let collectionViewInsets = collectionView.contentInset
        let width = collectionView.bounds.width - (collectionViewInsets.left + collectionViewInsets.right)
        return width
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        guard layoutAttributesСache.isEmpty else { return }
        guard let collectionView = collectionView else { return }
        guard numberOfColumns > 0 else { return }
        
        let maxHeight = collectionView.frame.height
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        
        var row = 0
        var itemIndex = 0
        
        let isEvenNumber = ((itemsCount % 2) != 0) ? false : true
        
        while (itemsCount - itemIndex) > 0 {
            let columnWidth: CGFloat
            
            if !isEvenNumber && row == 0 {
                columnWidth = contentWidth / CGFloat(numberOfColumns)
            } else {
                columnWidth = contentWidth / CGFloat(numberOfColumns) - columnSpacing / 2
            }
            
            let columnHeight: CGFloat
            
            switch itemsCount {
            case let count where count <= 1:
                columnHeight = maxHeight
            case let count where count <= 4:
                columnHeight = maxHeight / 2
            default:
                columnHeight = maxHeight / 3
            }

            var availableSpan = numberOfColumns
            (0..<numberOfColumns).forEach { column in
                guard itemIndex < itemsCount else { return }
                guard availableSpan > 0, availableSpan + column == numberOfColumns else { return }
                let indexPath = IndexPath(item: itemIndex, section: 0)

                let cellSpan: Int
                
                if !isEvenNumber && row == 0 || itemsCount == 2 {
                    cellSpan = 2
                } else {
                    cellSpan = 1
                }

                let cellWidth = columnWidth * CGFloat(cellSpan)
                
                let cellHeight = columnHeight

                let cellXPosition = CGFloat(column) * (columnWidth + columnSpacing)
                let cellYPosition = collectionViewHeight

                let cellOrigin = CGPoint(x: cellXPosition, y: cellYPosition)
                let cellSize = CGSize(width: cellWidth, height: cellHeight)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                layoutAttributes.frame = CGRect(origin: cellOrigin, size: cellSize)
                
                let frame = CGRect(x: cellOrigin.x, y: cellOrigin.y, width: cellSize.width, height: cellSize.height)
                let insetFrame = frame.insetBy(dx: 6, dy: 6)
                //attributes.frame = insetFrame
                layoutAttributesСache.append(layoutAttributes)

                itemIndex += 1
                availableSpan -= cellSpan
            }

            row += 1
            collectionViewHeight += columnHeight

            guard itemIndex < itemsCount else { continue }
            collectionViewHeight += rowSpacing
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        collectionViewHeight = 0
        layoutAttributesСache.removeAll()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in layoutAttributesСache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesСache[indexPath.item]
    }
}

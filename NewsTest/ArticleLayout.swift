//
//  ArticleLayout.swift
//  NewsTest
//
//  Created by JAGRAJ SINGH on 11/02/21.
//

import UIKit

enum LayoutStyle {
    case list
    case collection
}

protocol ArticleLayoutDelegate: class {
    var layoutStyle: LayoutStyle { get }
}


// I found about layouts for your instruction -> The screen has option for List View and Collection View.


// I've not done this layout thing before, just followed an article on internet and this is what i've learnt. I will dig deeper in UICollectionViewLayout later on...

class ArticleLayout: UICollectionViewLayout {
    
    weak var delegate: ArticleLayoutDelegate?
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        let style = delegate?.layoutStyle ?? .list
        
        let numberOfColumns: Int = 2
        let padding: CGFloat = 2
        let width: CGFloat = style == .list ? contentWidth : contentWidth / CGFloat(numberOfColumns)
        let height: CGFloat = padding * 2 + 200 // Height should be calculated dynamically
        
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * width)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: height)
            let insetFrame = frame.insetBy(dx: padding, dy: padding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            yOffset[column] = yOffset[column] + height
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache[indexPath.row]
    }
}



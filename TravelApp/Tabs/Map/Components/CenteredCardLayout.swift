//
//  CenteredCardLayout.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  CenteredCardLayout.swift
//  TravelApp
//

import UIKit

/// Horizontal flow layout that snaps each card to the center of the collection view.
/// Pair with `decelerationRate = .fast` for a tight, paginated feel.
final class CenteredCardLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 12
        minimumInteritemSpacing = 0
    }

    required init?(coder: NSCoder) { fatalError() }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }
        let pageWidth = itemSize.width + minimumLineSpacing
        guard pageWidth > 0 else { return proposedContentOffset }

        let approxPage = (proposedContentOffset.x + cv.contentInset.left) / pageWidth
        let targetPage: CGFloat
        if velocity.x > 0.1 {
            targetPage = ceil(approxPage)
        } else if velocity.x < -0.1 {
            targetPage = floor(approxPage)
        } else {
            targetPage = round(approxPage)
        }
        let lastPage = CGFloat(max((cv.numberOfItems(inSection: 0) - 1), 0))
        let clampedPage = min(max(targetPage, 0), lastPage)
        let targetX = clampedPage * pageWidth - cv.contentInset.left
        return CGPoint(x: targetX, y: proposedContentOffset.y)
    }
}
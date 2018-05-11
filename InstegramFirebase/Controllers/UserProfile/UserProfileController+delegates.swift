//
//  UserProfileController+delegates.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 11/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

extension UserProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

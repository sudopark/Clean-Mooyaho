//
//  UICollectionView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/22.
//

import UIKit


extension UICollectionView {
    
    public func registerCell<C: UICollectionViewCell>(_ cellType: C.Type,
                                                      with customReuseIdentifier: String? = nil) {
        let identifier = customReuseIdentifier ?? String(describing: cellType.self)
        self.register(cellType, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueCell<C: UICollectionViewCell>(with customIdentifier: String? = nil,
                                                     for indexPath: IndexPath) -> C {
        let identifier = customIdentifier ?? String(describing: C.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? C else {
            fatalError("not registered cell..")
        }
        return cell
    }
}

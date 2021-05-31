//
//  UITableView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/01.
//

import UIKit


extension UITableView {
    
    public func registerCell<C: UITableViewCell>(_ cellType: C.Type,
                                                 with customReuseIdentifier: String? = nil) {
        let identifier = customReuseIdentifier ?? String(describing: cellType.self)
        self.register(cellType, forCellReuseIdentifier: identifier)
    }
    
    public func dequeueCell<C: UITableViewCell>(with customIdentifier: String? = nil) -> C {
        let identifier = customIdentifier ?? String(describing: C.self)
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier) as? C else {
            fatalError("not registered cell..")
        }
        return cell
    }
}



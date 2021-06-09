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
    
    public func registerHeaderFooter<V: UITableViewHeaderFooterView>(_ viewType: V.Type ,
                                                                     with customIdentifier: String? = nil) {
        let identifier = customIdentifier ?? String(describing: viewType.self)
        self.register(viewType, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func dequeueCell<C: UITableViewCell>(with customIdentifier: String? = nil) -> C {
        let identifier = customIdentifier ?? String(describing: C.self)
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier) as? C else {
            fatalError("not registered cell..")
        }
        return cell
    }
    
    public func dequeueHeaderFooterView<V: UITableViewHeaderFooterView>(_ viewType: V.Type,
                                                                        with customIdentifier: String? = nil) -> V {
        let identifier = customIdentifier ?? String(describing: V.self)
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? V else {
            fatalError("not registered headerFooterView..")
        }
        return view
    }
}



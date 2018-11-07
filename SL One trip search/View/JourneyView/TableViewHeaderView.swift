//
//  TableViewHeaderView.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-29.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit



extension UITableView {
    func dequeueReusableHeaderFooterView<T: ReusableTableViewCell>() ->T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseId) as? T else {
            fatalError("Unable to deque or cast header/footer view.")
        }
        
        return view
    }
}

class TableViewHeaderView: UITableViewHeaderFooterView, ReusableTableViewCell {
    static let height: CGFloat = 25.0
    static let nibName = "TableViewHeaderView"
    @IBOutlet weak var titleLabel: UILabel!
}

//
//  OrderManagementTableViewCell.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/25.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

class OrderManagementTableViewCell: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var icon3Height: NSLayoutConstraint!
    @IBOutlet weak var label3TopSpace: NSLayoutConstraint!
    @IBOutlet weak var label3BottomSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  BottomUIView.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

class BottomUIView: UIView {

    @IBOutlet var contentView: BottomUIView!
    @IBOutlet weak var estimatedCostLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    override func awakeFromNib() {
        NSBundle.mainBundle().loadNibNamed("BottomUIView", owner: self, options: nil)
        self.addSubview(self.contentView)
        estimatedCostLabel.text = ""
    }
    
    func setContentViewFrame(frame: CGRect) {
        var rect = frame
        rect.origin.x = 0
        rect.origin.y = 0
        self.contentView.frame = rect
    }

}

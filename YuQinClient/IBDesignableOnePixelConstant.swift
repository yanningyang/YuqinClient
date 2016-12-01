//
//  IBDesignableOnePixelConstant.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

@IBDesignable

class IBDesignableOnePixelConstant: NSLayoutConstraint {
    
    @IBInspectable var onePixelConstant: CGFloat {
        get{
            return self.constant
        }
        set{
            self.constant = newValue * 1.0 / UIScreen.mainScreen().scale
        }
    }
}
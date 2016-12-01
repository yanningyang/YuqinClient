//
//  UIView+LoadFromNib.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public class func loadFromNibNamed(nibName: String) -> UIView {
        return FileOwner.viewFromnNibNamed(nibName)
    }
    
    public class func loadFromNib() -> UIView {
        return self.loadFromNibNamed(NSStringFromClass(self).componentsSeparatedByString(".").last!)
    }
}

//
//  FileOwner.swift
//  YuQinClient
//  
//  此类管理自定义UIView
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import UIKit

public class FileOwner: NSObject {
    
    @IBOutlet var view: UIView!
    
    public class func viewFromnNibNamed(nibName: String) -> UIView {
        
        let owner = FileOwner()
        NSBundle.mainBundle().loadNibNamed(nibName, owner: owner, options: nil)
        return owner.view
    }
}

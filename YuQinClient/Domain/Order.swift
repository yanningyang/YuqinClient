//
//  Order.swift
//  YuQinClient
//
//  Created by ksn_cn on 2016/12/12.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

public class Order {

}
enum OrderType: String, CustomStringConvertible {
    case day = "DAY"
    case mile = "MILE"
    case plane = "PLANE"
    
    var description: String {
        return self.rawValue
    }
}

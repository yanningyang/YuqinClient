//
//  UIViewControllerPassValueDelegate.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/18.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

@objc protocol UIViewControllerPassValueDelegate {
    optional func passValue(valueForBMKPoiInfo: BMKPoiInfo)
}
//
//  OperatorOverride.swift
//  YuQinClient
//
//  Created by ksn_cn on 2016/12/11.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

func += <KeyType, ValueType>(inout left: [KeyType : ValueType], right: [KeyType : ValueType]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

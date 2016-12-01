//
//  RegExHelper.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/21.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

class RegExHelper {
    
    var regex: NSRegularExpression?
    
    let phoneNumPattern = "^1[3578]\\d{9}"
    
    init(_ pattern: String) {
        do {
            try regex = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch let error {
            print("RegEx:", error)
            regex = nil
        }
    }
    
    func match(input: String) ->Bool {
        if let matchs = regex?.matchesInString(input, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, input.characters.count)) {
            return matchs.count > 0
        }
        return false
    }
    
    //匹配电话号码
    func matchPhoneNum(input: String) ->Bool {
        if input.characters.count > 11 {
            return false
        }
        do {
            try regex = NSRegularExpression(pattern: phoneNumPattern, options: .CaseInsensitive)
        } catch let error {
            print("RegEx error:", error)
            regex = nil
        }
        if let matchs = regex?.matchesInString(input, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, input.characters.count)) {
            return matchs.count > 0
        }
        return false
    }
}
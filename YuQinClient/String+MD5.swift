//
//  String+MD5.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/22.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

extension String {
    
    var md5: String! {
        
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strlen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestlen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestlen)
        
        CC_MD5(str!, strlen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestlen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestlen)
        
        return String(format: hash as String)
    }
}
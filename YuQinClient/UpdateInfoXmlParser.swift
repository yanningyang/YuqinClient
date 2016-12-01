//
//  UpdateInfoXmlParser.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/4/10.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

class UpdateInfoXmlParser: NSObject, NSXMLParserDelegate {
    
    static let sharedInstance = UpdateInfoXmlParser()
    //私有化init方法，保证单例
    private override init(){}
    
    private var updateInfo: UpdateInfo?
    
    //检查更新的方式（1:自动，2:手动）
    private var checkUpdateType: Int!
    
    private var currentTagName: String!
    
    func start(data: NSData, checkUpdateType: Int) {
        NSLog("开始解析 UpdateInfo XML...")
        
        self.checkUpdateType = checkUpdateType
        
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
    }
    
    func parserDidStartDocument(parser: NSXMLParser) {
        self.updateInfo = UpdateInfo()
        self.updateInfo!.checkUpdateType = self.checkUpdateType
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("parseError: %@", parseError)
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.currentTagName = elementName
        
        NSLog("currentTagName: %@", elementName)
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if let tag = self.currentTagName {
            
            switch tag {
            case "version":
                updateInfo?.version = string
            case "appID":
                updateInfo?.appId = string
            case "url":
                updateInfo?.url = string
            case "description":
                updateInfo?.description = string
            default:
                break
            }
        }
        
        NSLog("FoundCharacters: %@", string)
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.currentTagName = nil
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        NSLog("解析完成")
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidParserUpdateInfoXMLNotification, object: self.updateInfo)
    }
}

class UpdateInfo {
    var version: String?
    var appId: String?
    var url: String?
    var description: String?
    var checkUpdateType: Int?
}
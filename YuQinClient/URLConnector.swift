//
//  URLConnector.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/12/9.
//  Copyright © 2016年 CQU. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD
import SwiftyJSON

enum Router: URLRequestConvertible {
    
    case login(phoneNumber: String, validationCode: String)
    case getSMSCode(phoneNumber: String)
    case searchCustomerOrganization(keyword: String)
    case registCustomerInfo(customerName: String, customerOrganizationName: String)
    case getAllCarServiceType
    case getCarServiceTypeImage(carServiceTypeId: String)
    case getAllHistoryPassengers
    case submitOrder(params: [String : AnyObject])
    case getCustomerInfo
    case updateCustomerInfo(params: [String : AnyObject])
    case getOrdersByStatus(orderStatus: String, pageNum: String)
    case getOrdersInfo(orderId: String)
    case getAllFavoriateAddress
    case deleteHistoryAddress(address: String)
    case deleteHistoryPassenger(passengerIndex: String)
    case needRegistUserInfo
    case isOrderEvaluated(orderId: String)
    case getEvaluateGrade(orderId: String)
    case evaluateOrder(orderId: String, grade: String)
    case updateDeviceToken(deviceType: String, deviceToken: String)
    
    static let baseURLString = Constant.HOST_PATH
    
    var URLRequest: NSMutableURLRequest {
        
        var parameters: [String : AnyObject] = {
            let userInfo = Util.sharedInstance.getUserInfo()
            guard let phoneNumber = userInfo.0, validationCode = userInfo.1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
                print("从本地获取登录信息失败!")
                return [String : AnyObject]()
            }
            return ["phoneNumber" : phoneNumber, "validationCode" : validationCode]
        }()
        
        parameters["companyId"] = Constant.COMPANY_ID
        
        let result: (path: String, parameters: [String: AnyObject]) = {
            switch self {
            case let .login(phoneNumber, validationCode):
                parameters.removeAll()
                parameters["companyId"] = Constant.COMPANY_ID
                parameters["phoneNumber"] = phoneNumber
                parameters["validationCode"] = validationCode
                return ("/OrderApp_login.action", parameters)
            case let .getSMSCode(phoneNumber):
                parameters.removeAll()
                parameters["companyId"] = Constant.COMPANY_ID
                parameters["phoneNumber"] = phoneNumber
                return ("/user_getSMSCode.action", parameters)
            case let .searchCustomerOrganization(keyword):
                parameters["keyword"] = keyword
                return ("/OrderApp_searchCustomerOrganization.action", parameters)
            case let .registCustomerInfo(customerName, customerOrganizationName):
                parameters["customerName"] = customerName
                parameters["customerOrganizationName"] = customerOrganizationName
                return ("/OrderApp_registCustomerInfo.action", parameters)
            case .getAllCarServiceType:
                return ("/OrderApp_getAllCarServiceType.action", parameters)
            case let .getCarServiceTypeImage(carServiceTypeId):
                parameters["carServiceTypeId"] = carServiceTypeId
                return ("/OrderApp_getCarServiceTypeImage.action", parameters)
                
            case .getAllHistoryPassengers:
                return ("/OrderApp_getAllHistoryPassengers.action", parameters)
            case let .submitOrder(params):
                for (k, v) in params {
                    parameters.updateValue(v, forKey: k)
                }
                return ("/OrderApp_submitOrder.action", parameters)
            case .getCustomerInfo:
                return ("/OrderApp_getCustomerInfo.action", parameters)
            case let .updateCustomerInfo(params):
                for (k, v) in params {
                    parameters.updateValue(v, forKey: k)
                }
                return ("/OrderApp_updateCustomerInfo.action", parameters)
            case let .getOrdersByStatus(orderStatus, pageNum):
                parameters["orderStatus"] = orderStatus
                parameters["pageNum"] = pageNum
                return ("/OrderApp_getOrdersByStatus.action", parameters)
            case let .getOrdersInfo(orderId):
                parameters["orderId"] = orderId
                return ("/OrderApp_getOrdersInfo.action", parameters)
            case .getAllFavoriateAddress:
                return ("/OrderApp_getAllFavoriateAddress.action", parameters)
            case let .deleteHistoryAddress(address):
                parameters["address"] = address
                return ("/OrderApp_deleteHistoryAddress.action", parameters)
            case let .deleteHistoryPassenger(passengerIndex):
                parameters["passengerIndex"] = passengerIndex
                return ("/OrderApp_deleteHistoryPassenger.action", parameters)
            case .needRegistUserInfo:
                return ("/OrderApp_needRegistUserInfo.action", parameters)
            case let .isOrderEvaluated(orderId):
                parameters["orderId"] = orderId
                return ("/OrderApp_isOrderEvaluated.action", parameters)
            case let .getEvaluateGrade(orderId):
                parameters["orderId"] = orderId
                return ("/OrderApp_getEvaluateGrade.action", parameters)
            case let .evaluateOrder(orderId, grade):
                parameters["orderId"] = orderId
                parameters["grade"] = grade
                return ("/OrderApp_evaluateOrder.action", parameters)
            case let .updateDeviceToken(deviceType, deviceToken):
                parameters["deviceType"] = deviceType
                parameters["deviceToken"] = deviceToken
                return ("/OrderApp_updateDeviceToken.action", parameters)
            }
            
        }()
        
        let url = NSURL(string: Router.baseURLString)
        let urlRequest = NSURLRequest(URL: url!.URLByAppendingPathComponent(result.path)!)
        return Alamofire.ParameterEncoding.URL.encode(urlRequest, parameters: result.parameters).0
    }
}

public class URLConnector {
    
    class func request(urlRequest: URLRequestConvertible, showLoadingAnimation: Bool = false, successCallBack: (JSON) -> (), failureCallBack: (NSError) -> () = {_ in return}) {
        
        var HUD: MBProgressHUD!
        if showLoadingAnimation {
            //等待动画
            HUD = UITools.sharedInstance.showLoadingAnimation()
        }
        
        print("😄", "Action", urlRequest)
        print("😄", "requestl URL: ", "\(urlRequest.URLRequest.URL?.absoluteString)")
        
        Alamofire.request(urlRequest)
            .responseJSON { response in
                
                if showLoadingAnimation {
                    //取消等待动画
                    HUD.hide(true)
                }
                
                switch (response.result) {
                case .Success(let value):
                    let json = JSON(value)
                    if let error_code = json["status"].string {
                        if error_code == UNAUTHORIZED {
                            print("❌无权限: \(urlRequest)")
                        } else if error_code == BAD_PARAMETER {
                            print("❌参数错误: \(urlRequest)")
                        } else {
                            
                        }
                    } else {
                        print("✅\(urlRequest): ", value)
                        successCallBack(json)
                    }
                case .Failure(let error):
                    print("❌\(urlRequest): ", error)
                    failureCallBack(error)
                }
        }
    }

    /// 后台下载
    class func download(urlRequest: URLRequestConvertible, localFileName: String, downloadComplete: (Bool, NSURL?) -> () = {_, _ in return}, downloadProgress: (Double) -> () = {_ in return}) {
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(localFileName)
        print("destination URL: \(fileURL)")
        let destination: Request.DownloadFileDestination = { _, _ in fileURL! }
        
        print("开始下载: \(urlRequest)")
        Alamofire.download(urlRequest, destination: destination).response { request, response, data, error in
            print("response.request: \(request)")
            
            if error != nil {
                print("\(urlRequest) ===== download error: \(error.debugDescription)")
                downloadComplete(false, fileURL)
            } else if let filePath = fileURL!.path {
                print("下载结束：\(filePath)")
                downloadComplete(true, fileURL)
            } else {
                print("下载目标路径异常")
            }
        }.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            print("Download Progress: \(totalBytesRead / totalBytesExpectedToRead)")
            let progress = Double(totalBytesRead) / Double(totalBytesExpectedToRead)
            downloadProgress(progress)
        }
    }
}

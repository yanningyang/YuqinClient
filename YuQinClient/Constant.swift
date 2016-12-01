//
//  Constant.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/17.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import UIKit

//鉴权失败
public let UNAUTHORIZED = "unauthorized"
//接口参数错误
public let BAD_PARAMETER = "badParameter"

//baidu map key
public let BAIDUMAP_KEY = "lz2EosqOLhZ64l1jhjdYQgKW"

public class Constant {
    
    //测试服务器地址
//    public static let HOST_NAME = "http://172.20.143.60"
    public static let HOST_NAME = "http://101.201.31.147"
    public static let HOST_PATH = HOST_NAME + "/orderapp"
    //检查版本地址
    public static let CheckUpdateUrl = HOST_NAME + "/apk/CustomerAPPUpdate.xml"
    
    //百度资源
    public static let MYBUNDLE_NAME = "mapapi.bundle"
    
    //CollectionView高度
    public static let CollectionViewHeight: CGFloat = 90
    public static let CollectionCellViewWidth: CGFloat = 110
    public static let CollectionCellViewHeight: CGFloat = 78
    
    //列表底部的信息
    public static let TableViewFootorLabel_1 = "套餐价¥50.0(含20分钟8公里)"
    public static let TableViewFootorLabel_2 = "超出按¥0.5/分钟＋¥4.1/公里计费"
    public static let TableViewFootorLabel_3 = "大众帕萨特 丰田凯美瑞或类似5座车型"
    
    //通知
    //立即叫车界面选择完乘车人
    public static let CallTaxiNowViewControllerDidSelectCustomerNofification = "CallTaxiNowViewControllerDidSelectCustomerNofification"
    //立即叫车界面选择完开始地址
    public static let CallTaxiNowViewControllerDidSelectStartAddressNofification = "CallTaxiNowViewControllerDidSelectStartAddressNofification"
    //立即叫车界面选择完目的地地址
    public static let CallTaxiNowViewControllerDidSelectEndAddressNofification = "CallTaxiNowViewControllerDidSelectEndAddressNofification"
    //立即叫车界面选择完收藏开始地址
    public static let CallTaxiNowViewControllerDidSelectFavStartAddressNofification = "CallTaxiNowViewControllerDidSelectFavStartAddressNofification"
    //立即叫车界面选择完收藏目的地地址
    public static let CallTaxiNowViewControllerDidSelectFavEndAddressNofification = "CallTaxiNowViewControllerDidSelectFavEndAddressNofification"
    
    //预约车界面选择完乘车人
    public static let CallTaxiByReservingViewControllerDidSelectCustomerNofification = "CallTaxiByReservingViewControllerDidSelectCustomerNofification"
    //预约车界面选择完开始地址
    public static let CallTaxiByReservingViewControllerDidSelectStartAddressNofification = "CallTaxiByReservingViewControllerDidSelectStartAddressNofification"
    //预约车界面选择完目的地地址
    public static let CallTaxiByReservingViewControllerDidSelectEndAddressNofification = "CallTaxiByReservingViewControllerDidSelectEndAddressNofification"
    //预约车界面选择完收藏开始地址
    public static let CallTaxiByReservingViewControllerDidSelectFavStartAddressNofification = "CallTaxiByReservingViewControllerDidSelectFavStartAddressNofification"
    //预约车界面选择完收藏目的地地址
    public static let CallTaxiByReservingViewControllerDidSelectFavEndAddressNofification = "CallTaxiByReservingViewControllerDidSelectFavEndAddressNofification"
    
    //日租车界面选择完乘车人
    public static let CallTaxiDailyViewControllerDidSelectCustomerNofification = "CallTaxiDailyViewControllerDidSelectCustomerNofification"
    //日租车界面选择完开始地址
    public static let CallTaxiDailyViewControllerDidSelectStartAddressNofification = "CallTaxiDailyViewControllerDidSelectStartAddressNofification"
    //日租车界面选择完目的地地址
    public static let CallTaxiDailyViewControllerDidSelectEndAddressNofification = "CallTaxiDailyViewControllerDidSelectEndAddressNofification"
    //日租车界面选择完收藏开始地址
    public static let CallTaxiDailyViewControllerDidSelectFavStartAddressNofification = "CallTaxiDailyViewControllerDidSelectFavStartAddressNofification"
    //日租车界面选择完收藏目的地地址
    public static let CallTaxiDailyViewControllerDidSelectFavEndAddressNofification = "CallTaxiDailyViewControllerDidSelectFavEndAddressNofification"
    
    //选择完城市通知
    public static let DidSelectCityNofification = "DidSelectCityNofification"
    
    //个人信息获取成功通知
    public static let DidGetCustomerInfoNofification = "DidGetCustomerInfoNofification"
    
    //已结束订单界面选择完评价等级通知
    public static let OrderManagementViewControllerDidSelectEvaluationGradeNofification = "OrderManagementViewControllerDidSelectEvaluationGradeNofification"
    
    //收到远程通知
    public static let DidReceiveRemoteNotification = "DidReceiveRemoteNotification"
    
    //解析升级信息完成通知
    public static let DidParserUpdateInfoXMLNotification = "DidParserUpdateInfoXMLNotification"
    
    // MARK -- UserDefault Keys
    public static let KeyForPhoneNumber = "phoneNumber"
    public static let KeyForValidationCode = "validationCode"
    public static let KeyForCustomerName = "name"
    public static let KeyForCustomerOrganizationName = "organizationName"
    public static let KeyForCustomerGender = "gender"
}

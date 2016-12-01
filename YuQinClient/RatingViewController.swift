//
//  RatingViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/4/8.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class RatingViewController: UIViewController {

    @IBOutlet weak var ratingBarView: UIView!
    @IBOutlet weak var orderSNLabel: UILabel!
    
    var ratingBar: RatingBar!
    
    var dataDict: Dictionary<String, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //添加右上角按钮
        let rightBarBtnItem = UIBarButtonItem(title: "确定", style: .Plain, target: self, action: #selector(onClickRightBarBtn(_:)))
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        //初始化评分控件
        ratingBar = RatingBar()
        ratingBarView.addSubview(ratingBar)
        ratingBar.translatesAutoresizingMaskIntoConstraints = false
        ratingBar.numStars = 5
        if let isOrderEvaluated = dataDict["isOrderEvaluated"] as? Bool {
            ratingBar.isIndicator = isOrderEvaluated
            
            if isOrderEvaluated {
                
                getOrderEvaluationGrade(dataDict["id"] as! Int)
            }
        }
        
        let views = ["ratingBar" : ratingBar] as [String : AnyObject]
        let constraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[ratingBar]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        let constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[ratingBar]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        ratingBar.superview?.addConstraints(constraints1)
        ratingBar.superview?.addConstraints(constraints2)
        
        getOrderDetailById(dataDict["id"] as! Int)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickRightBarBtn(sender: UIButton) {
        print("rating: \(ratingBar.rating)")
        
        if let isOrderEvaluated = dataDict["isOrderEvaluated"] as? Bool where !isOrderEvaluated {
            
            guard ratingBar.rating != 0 else {
                popAlertForConfirmGrade()
                return
            }
            dataDict["grade"] = ratingBar.rating
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.OrderManagementViewControllerDidSelectEvaluationGradeNofification, object: nil, userInfo: dataDict)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //确认订单评分是否为 0
    func popAlertForConfirmGrade() {
        let alertController = UIAlertController(title: "确定评分为 0 ？", message: "", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "取消", style: .Default) { alertAction in
            NSLog("用户点击取消")
        }
        let ok = UIAlertAction(title: "确定", style: .Default) { alertAction in
            NSLog("用户点击确认")
            
            self.dataDict["grade"] = self.ratingBar.rating
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.OrderManagementViewControllerDidSelectEvaluationGradeNofification, object: nil, userInfo: self.dataDict)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancel)
        alertController.addAction(ok)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func getOrderEvaluationGrade(orderId: Int) {
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        //url和参数
        let url = Constant.HOST_PATH + "/OrderApp_getEvaluateGrade.action"
        let parameters = ["phoneNumber" : phoneNumber,
                          "validationCode" : validationCode,
                          "orderId" : orderId]
        
        Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                print("OrderApp_getEvaluateGrade.action request: \(response.request)")
                
                switch (response.result) {
                case .Success(let value):
                    print("get order evaluate grade by orderId(\(orderId)) result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let grade = value["grade"] as? Int {
                        self.dataDict["grade"] = grade
                        self.ratingBar.rating = CGFloat(grade)
                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }
    
    func getOrderDetailById(orderId: Int) {

        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        
        //url和参数
        let url = Constant.HOST_PATH + "/OrderApp_getOrdersInfo.action"
        let parameters = ["phoneNumber" : phoneNumber,
                          "validationCode" : validationCode,
                          "orderId" : orderId]
        Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                switch (response.result) {
                case .Success(let value):
                    print("get order detail by Id result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let dataDict = value as? Dictionary<String, AnyObject> {
                        
                        self.orderSNLabel.text = dataDict["sN"] as? String
                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }

}

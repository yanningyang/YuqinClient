//
//  OrderDetailViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/26.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class OrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var orderId: Int!
    
    var dataList = [Dictionary<String, String>]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.hidesBottomBarWhenPushed = true
        
        self.navigationItem.title = "详细信息"
        
        closeBtn.setImage(UIImage(named: "BtnClose")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        getOrderById()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForOrderDetail", forIndexPath: indexPath) as! OrderDetailTableViewCell
        
        let dict = dataList[indexPath.row]
        cell.label1.text = dict["label1"]
        cell.label2.text = dict["label2"]
        
        return cell
    }
    
    @IBAction func closeBtnAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadData(dataDict :Dictionary<String, AnyObject>) {
            
        dataList.removeAll()
        
        var dict1 = Dictionary<String, String>()
        dict1["label1"] = "订单号"
        dict1["label2"] = dataDict["sN"] as? String
        dataList.append(dict1)
        
        var dict2 = Dictionary<String, String>()
        dict2["label1"] = "乘车人"
        dict2["label2"] = dataDict["passenger"] as? String
        dataList.append(dict2)
        
        var dict3 = Dictionary<String, String>()
        dict3["label1"] = "时间"
        dict3["label2"] = dataDict["time"] as? String
        dataList.append(dict3)
        
        var dict4 = Dictionary<String, String>()
        dict4["label1"] = "上车地址"
        dict4["label2"] = dataDict["fromAddress"] as? String
        dataList.append(dict4)
        
        if let toAddress = dataDict["toAddress"] as? String where !toAddress.isEmpty {
            var dict5 = Dictionary<String, String>()
            dict5["label1"] = "下车地址"
            dict5["label2"] = toAddress
            dataList.append(dict5)
        }
        
        var dict6 = Dictionary<String, String>()
        dict6["label1"] = "车型"
        dict6["label2"] = dataDict["carServiceType"] as? String
        dataList.append(dict6)
        
        var dict7 = Dictionary<String, String>()
        dict7["label1"] = "订单状态"
        dict7["label2"] = dataDict["orderStatus"] as? String
        dataList.append(dict7)
        
        var dict8 = Dictionary<String, String>()
        dict8["label1"] = "司机"
        dict8["label2"] = dataDict["driver"] as? String
        dataList.append(dict8)
        
        tableView.reloadData()
    }

    func getOrderById() {
        guard orderId != nil else {
            return
        }
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
                        
                        self.loadData(dataDict)
                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }

}

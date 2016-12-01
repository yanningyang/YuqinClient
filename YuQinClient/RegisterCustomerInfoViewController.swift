//
//  RegisterCustomerInfoViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/23.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class RegisterCustomerInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var customerOrganizationTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var organizationList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarBtn = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: #selector(onClickRightBarBtn(_:)))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:))))
        
        //实时检索
        customerOrganizationTextField.addTarget(self, action: #selector(searchCustomerOrganization), forControlEvents: .EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForSelectOrganization", forIndexPath: indexPath)
        cell.textLabel?.text = organizationList[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("didSelectRowAtIndexPath %d", indexPath.row)
        
        customerOrganizationTextField.text = organizationList[indexPath.row]
        tableView.hidden = true
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        NSLog("tableView start scroll")
        
        customerOrganizationTextField.resignFirstResponder()
    }
    
    func onClickRightBarBtn(sender: UIBarButtonItem) {
        print("right barBtn is clicked @ RegisterCustomerInfoViewController")
        submitCustomerInfo()
    }
    
    func onTapBackgroundView(sender: UITapGestureRecognizer) {
        customerNameTextField.resignFirstResponder()
        customerOrganizationTextField.resignFirstResponder()
    }
    
    func searchCustomerOrganization() {
        
        if let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty {
            
            var keyword = ""
            if customerOrganizationTextField.text != nil {
                keyword = customerOrganizationTextField.text!
            }
            
            //url和参数
            let url = Constant.HOST_PATH + "/OrderApp_searchCustomerOrganization.action"
            let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode, "keyword" : keyword]
            
            Alamofire.request(.GET, url, parameters: parameters)
                .responseJSON { response in
                    
                    switch (response.result) {
                    case .Success(let value):
                        print("get organization name result: \(value)")
                        
                        if let data = value as? [String] {
                            self.organizationList = data
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                        }
                        
                    case .Failure(let error):
                        NSLog("Error: %@", error)
                    }
            }
        } else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
        }
    }
    
    func submitCustomerInfo() {
        
        let customerName = customerNameTextField.text
        let customerOrganization = customerOrganizationTextField.text
        if customerName == nil || customerName!.isEmpty {
            UITools.sharedInstance.toast("请输入姓名")
            
            UITools.sharedInstance.shakeView(customerNameTextField)
            return
        }
        if customerOrganization == nil || customerOrganization!.isEmpty {
            UITools.sharedInstance.toast("请输入单位名称")
            
            UITools.sharedInstance.shakeView(customerOrganizationTextField)
            return
        }
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        //等待动画
        let HUD = UITools.sharedInstance.showLoadingAnimation()
        //url和参数
        let url = Constant.HOST_PATH + "/OrderApp_registCustomerInfo.action"
        let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode, "customerName" : customerName!, "customerOrganizationName" : customerOrganization!]
        
        Alamofire.request(Method.GET, url, parameters: parameters)
            .responseJSON { response in
                
                //取消等待动画
                HUD.hide(true)
                
                switch (response.result) {
                case .Success(let value):
                    print("regist customer info result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let status = value["status"] as? Bool {
                        
                        if status {
                            NSLog("登记成功")
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setBool(true, forKey: "isRegisteredCustomerInfo")
                            //上传token
                            Tools.sharedInstance.updateDeviceToken()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        } else {
                            NSLog("登记失败")
                        }
                    }
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }

}

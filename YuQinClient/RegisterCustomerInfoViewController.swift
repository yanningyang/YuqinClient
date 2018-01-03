//
//  RegisterCustomerInfoViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/23.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterCustomerInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var customerOrganizationTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var organizationList: [JSON] = { [JSON]() }()
    
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
        cell.textLabel?.text = organizationList[indexPath.row].string
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("didSelectRowAtIndexPath %d", indexPath.row)
        
        customerOrganizationTextField.text = organizationList[indexPath.row].string
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
        
        var keyword = ""
        if customerOrganizationTextField.text != nil {
            keyword = customerOrganizationTextField.text!
        }
        URLConnector.request(Router.searchCustomerOrganization(keyword: keyword), successCallBack: { value in
            if let list = value.array {
                self.organizationList = list
                self.tableView.reloadData()
                self.tableView.hidden = false
            }
        })
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
        
        URLConnector.request(Router.registCustomerInfo(customerName: customerName!, customerOrganizationName: customerOrganization!), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    print("登记成功")
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setBool(true, forKey: "isRegisteredCustomerInfo")
                    //上传token
                    Tools.sharedInstance.updateDeviceToken()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    print("登记失败")
                }
            }
        })
    }

}

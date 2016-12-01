//
//  FavPassengersManagementViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/26.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class FavPassengersManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var favPassengersList = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "历史乘客"
        self.automaticallyAdjustsScrollViewInsets = false
        self.hidesBottomBarWhenPushed = true
        
        //去除多余分割线
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        //添加右上角编辑按钮
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem?.title = "编辑"
        
        getAllFavPassengers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        self.navigationItem.setHidesBackButton(editing, animated: true)
        if editing {
            self.navigationItem.rightBarButtonItem?.title = "完成"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "编辑"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favPassengersList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForFavPassengersManagement", forIndexPath: indexPath)
        cell.textLabel?.text = favPassengersList[indexPath.row]["name"] as? String
        cell.detailTextLabel?.text = favPassengersList[indexPath.row]["phoneNumber"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        deleteFavPassengersByIndex(indexPath)
    }
    
    func getAllFavPassengers() {
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        
        //url和参数
        let url = Constant.HOST_PATH + "/OrderApp_getAllHistoryPassengers.action"
        let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode]
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                print("OrderApp_getAllHistoryPassengers.action request: \(response.request)")
                
                switch (response.result) {
                case .Success(let value):
                    print("get all fav Passengers result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let list = value as? [Dictionary<String, AnyObject>] {
                        
                        self.favPassengersList = list
                        self.tableView.reloadData()
                        
                        self.favPassengersList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.tableView, tipStr: "暂无常用联系人") : UITools.sharedInstance.hideNoDataTipFromView(self.tableView)
                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }
    
    func deleteFavPassengersByIndex(indexPath: NSIndexPath) {
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        
        //等待动画
        let HUD = UITools.sharedInstance.showLoadingAnimation()
        //url和参数
        let url = Constant.HOST_PATH + "/OrderApp_deleteHistoryAddress.action"
        let parameters = ["phoneNumber" : phoneNumber,
                          "validationCode" : validationCode,
                          "passengersIndex" : favPassengersList[indexPath.row]["index"] as! Int]
        
        Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                
                //取消等待动画
                HUD.hide(true)
                
                switch (response.result) {
                case .Success(let value):
                    print("delete fac Passengers by index result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let status = value["status"] as? Bool {
                        
                        if status {
                            
                            self.favPassengersList.removeAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        } else {
                            
                            UITools.sharedInstance.toast("删除失败，请重试")
                        }
                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }

}

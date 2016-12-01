//
//  FavAddressManagementViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/26.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class FavAddressManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var favAddressList = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "常用地址"
        self.automaticallyAdjustsScrollViewInsets = false
        self.hidesBottomBarWhenPushed = true
        
        //去除多余分割线
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //添加右上角编辑按钮
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem?.title = "编辑"

        getAllFavAddress()
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
        return favAddressList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForFavAddressManagement", forIndexPath: indexPath)
        cell.textLabel?.text = favAddressList[indexPath.row]["description"] as? String
        cell.detailTextLabel?.text = favAddressList[indexPath.row]["detail"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        deleteFavAddressByIndex(indexPath)
    }
    
    func onClickRightBarBtn(sender: UIBarButtonItem) {
    
    }
    
    func getAllFavAddress() {
        
        if let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty {
            
            //url和参数
            let url = Constant.HOST_PATH + "/OrderApp_getAllFavoriateAddress.action"
            let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode]
            
            Alamofire.request(.GET, url, parameters: parameters)
                .responseJSON { response in
                    
                    switch (response.result) {
                    case .Success(let value):
                        print("get all fav address result: \(value)")
                        
                        if let status = value["status"] as? String {
                            if status == UNAUTHORIZED {
                                NSLog("\(url) 无权限")
                            } else if status == BAD_PARAMETER {
                                NSLog("\(url) 参数错误")
                            }
                            
                        } else if let list = value as? [Dictionary<String, AnyObject>] {
                            
                            self.favAddressList = list
                            self.tableView.reloadData()
                            
                            self.favAddressList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.tableView, tipStr: "暂无常用地址") : UITools.sharedInstance.hideNoDataTipFromView(self.tableView)
                        }
                        
                    case .Failure(let error):
                        NSLog("Error: %@", error)
                    }
            }
        } else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
        }
    }
    
    func deleteFavAddressByIndex(indexPath: NSIndexPath) {
        
        if let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty {
            
            //等待动画
            let HUD = UITools.sharedInstance.showLoadingAnimation()
            //url和参数
            let url = Constant.HOST_PATH + "/OrderApp_deleteHistoryAddress.action"
            let parameters = ["phoneNumber" : phoneNumber,
                              "validationCode" : validationCode,
                              "addressIndex" : favAddressList[indexPath.row]["index"] as! Int]
            
            Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
                .responseJSON { response in
                    
                    //取消等待动画
                    HUD.hide(true)
                    
                    switch (response.result) {
                    case .Success(let value):
                        print("delete fac address by index result: \(value)")
                        
                        if let status = value["status"] as? String {
                            if status == UNAUTHORIZED {
                                NSLog("\(url) 无权限")
                            } else if status == BAD_PARAMETER {
                                NSLog("\(url) 参数错误")
                            }
                            
                        } else if let status = value["status"] as? Bool {
                            
                            if status {
                                self.favAddressList.removeAtIndex(indexPath.row)
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            } else {
                                UITools.sharedInstance.toast("删除失败，请重试")
                            }
                        }
                        
                    case .Failure(let error):
                        NSLog("Error: %@", error)
                    }
            }
        } else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
        }
    }
}

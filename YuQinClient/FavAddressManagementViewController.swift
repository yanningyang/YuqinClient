//
//  FavAddressManagementViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/26.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FavAddressManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var favAddressList: [JSON] = { [JSON]() }()
    
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
        cell.textLabel?.text = favAddressList[indexPath.row].string
//        cell.textLabel?.text = favAddressList[indexPath.row]["description"].string
//        cell.detailTextLabel?.text = favAddressList[indexPath.row]["detail"].string
        
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
        
        URLConnector.request(Router.getAllFavoriateAddress, successCallBack: { value in
            if let list = value.array {
                self.favAddressList = list
                self.tableView.reloadData()
                
                self.favAddressList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.tableView, tipStr: "暂无常用地址") : UITools.sharedInstance.hideNoDataTipFromView(self.tableView)
            }
        })
    }
    
    func deleteFavAddressByIndex(indexPath: NSIndexPath) {
        
        URLConnector.request(Router.deleteHistoryAddress(address: favAddressList[indexPath.row].string!), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    self.favAddressList.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                } else {
                    UITools.sharedInstance.toast("删除失败，请重试")
                }
            }
        })
    }
}

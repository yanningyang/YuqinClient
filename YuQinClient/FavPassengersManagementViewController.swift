//
//  FavPassengersManagementViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/26.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FavPassengersManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var favPassengersList: [JSON] = { [JSON]() }()
    
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
        cell.textLabel?.text = favPassengersList[indexPath.row]["name"].string
        cell.detailTextLabel?.text = favPassengersList[indexPath.row]["phoneNumber"].string
        
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
        
        URLConnector.request(Router.getAllHistoryPassengers, successCallBack: { value in
            if let list = value.array {
                self.favPassengersList = list
                self.tableView.reloadData()
                
                self.favPassengersList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.tableView, tipStr: "暂无常用联系人") : UITools.sharedInstance.hideNoDataTipFromView(self.tableView)
            }
        })
    }
    
    func deleteFavPassengersByIndex(indexPath: NSIndexPath) {
        
        URLConnector.request(Router.deleteHistoryPassenger(passengerIndex: "\(favPassengersList[indexPath.row]["index"].int)"), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    self.favPassengersList.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                } else {
                    
                    UITools.sharedInstance.toast("删除失败，请重试")
                }
            }
        })
    }

}

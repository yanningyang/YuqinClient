//
//  SelectFavoriteAddressViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/20.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class SelectFavoriteAddressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var identifier: String!
    
    var favAddressList: [AddressInfo] = { [AddressInfo]() }()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let rightBarBtnItem = UIBarButtonItem(title: "确定", style: .Plain, target: self, action: #selector(onClickRightBarBtn(_:)))
//        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        //去除多余分割线
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        getAllFavAddress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favAddressList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForFavAddressList", forIndexPath: indexPath) 
        cell.textLabel?.text = favAddressList[indexPath.row].name
        cell.detailTextLabel?.text = favAddressList[indexPath.row].detail
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        NSNotificationCenter.defaultCenter().postNotificationName(identifier, object: favAddressList[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onClickRightBarBtn(sender: UIBarButtonItem) {
        print("right barBtn is clicked @ SelectedFavoriteAddressViewController")
    }
    
    func getAllFavAddress() {
        
        URLConnector.request(Router.getAllFavoriateAddress, successCallBack: { value in
            if let list = value.array {
                for item in list {
                    let addressInfo = AddressInfo()
                    addressInfo.name = item.string
                    self.favAddressList.append(addressInfo)
                }
                
                self.favAddressList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.view, tipStr: "暂无常用地址") : UITools.sharedInstance.hideNoDataTipFromView(self.view)
                
                self.tableView.reloadData()
            }
        })
    }

}

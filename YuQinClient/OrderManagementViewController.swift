//
//  OrderManagementViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/24.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import pop
import Alamofire
import MJRefresh
import STPopup
import SwiftyJSON

class OrderManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var titleBtn: UIButton!
    var titleBtnImg: UIImageView!
    
    @IBOutlet weak var menuTopSpaceConstant: NSLayoutConstraint!
    
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var orderTableView: UITableView!
    
    var selectedMenuItemIndex = 1 {
        didSet {
            currentPage = 1
            pageCount = 0
            
            menuTableView.reloadData()
            titleBtn.setTitle(menuDataList[selectedMenuItemIndex], forState: .Normal)
            self.orderTableView.mj_header.beginRefreshing()
        }
    }
    let menuDataList = ["等待行程", "当前行程", "历史行程", "取消行程"]
    let orderStatus = ["WAIT", "BEGIN", "END", "CANCELLED"]
    
    let cellForOrderManagementMenu = "CellForOrderManagementMenu"
    let cellForOrderManagement = "CellForOrderManagement"
    let cellForEndOrderManagement = "CellForEndOrderManagement"
    
    var orderList: [JSON] = { [JSON]() }()
    var orderEvaluateStatusDict: [Int : Bool] = { [Int : Bool]() }()
    var currentPage = 1
    var pageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载TitleView
        let titleView = UIView.loadFromNibNamed("OrderManagementTitleView")
        titleBtn = titleView.viewWithTag(1) as! UIButton
        titleBtn.setTitle("当前行程", forState: .Normal)
        titleBtn.addTarget(self, action: #selector(titleBtnAction(_:)), forControlEvents: .TouchUpInside)
        titleBtnImg = titleView.viewWithTag(2) as! UIImageView
        titleBtnImg.image = UIImage(named: "IconArrowDown")?.imageWithRenderingMode(.AlwaysTemplate)
        titleBtnImg.tintColor = UIColor.whiteColor()
        self.navigationItem.titleView = titleView

        //为表视图注册Nib
        let cellNib1 = UINib(nibName: "OrderManagementMenuTableViewCell", bundle: nil)
        menuTableView.registerNib(cellNib1, forCellReuseIdentifier: cellForOrderManagementMenu)
        let cellNib2 = UINib(nibName: "OrderManagementTableViewCell", bundle: nil)
        orderTableView.registerNib(cellNib2, forCellReuseIdentifier: cellForOrderManagement)
        let cellNib3 = UINib(nibName: "EndOrderManagementTableViewCell", bundle: nil)
        orderTableView.registerNib(cellNib3, forCellReuseIdentifier: cellForEndOrderManagement)
        //添加下啦刷新控件
        orderTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        orderTableView.mj_header.automaticallyChangeAlpha = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        orderTableView.estimatedRowHeight = 80
        orderTableView.rowHeight = UITableViewAutomaticDimension
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(evaluateOrder(_:)), name: Constant.OrderManagementViewControllerDidSelectEvaluationGradeNofification, object: nil)
        
        //点击此背景收起菜单
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDimmingView)))
        //加载订单
        self.orderTableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return menuDataList.count
        } else {
            return orderList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if tableView == menuTableView {
            cell = tableView.dequeueReusableCellWithIdentifier(cellForOrderManagementMenu, forIndexPath: indexPath)
            let cell1 = cell as! OrderManagementMenuTableViewCell
            
            let row = indexPath.row
            cell1.label.text = menuDataList[row]
            
            if selectedMenuItemIndex == row {
                cell1.imgView.hidden = false
            } else {
                cell1.imgView.hidden = true
            }
            
        } else {
            if selectedMenuItemIndex == 2 {
                cell = tableView.dequeueReusableCellWithIdentifier(cellForEndOrderManagement, forIndexPath: indexPath) as! EndOrderManagementTableViewCell
                let cell1 = cell as! EndOrderManagementTableViewCell
                let order = orderList[indexPath.row]
                cell1.label1.text = order["time"].string
                cell1.label2.text = order["fromAddress"].string
                cell1.label3.text = order["toAddress"].string
                if let toAddress = order["toAddress"].string where !toAddress.isEmpty {
                    cell1.icon3Height.constant = 20
                    cell1.label3TopSpace.constant = 8
                } else {
                    cell1.icon3Height.constant = 0
                    cell1.label3TopSpace.constant = 0
                }
                var passenger = order["otherPassenger"].string
                if passenger == nil || passenger!.isEmpty {
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    if let phoneNumber = userDefault.stringForKey(Constant.KeyForPhoneNumber) {
                        passenger = "本人（\(phoneNumber)）"
                    }
                }
                cell1.label4.text = passenger
                
                if cell1.button != nil {
                    
                    cell1.button.tag = indexPath.row
                    if let isOrderEvaluated = orderEvaluateStatusDict[order["id"].int!] {
                        cell1.button.hidden = false
                        cell1.button.setTitle(isOrderEvaluated ? "已评价" : "评价", forState: .Normal)
                        
                    } else {
                        cell1.button.hidden = true
                    }
                    cell1.button.addTarget(self, action: #selector(popupRatingController(_:)), forControlEvents: .TouchUpInside)
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(cellForOrderManagement, forIndexPath: indexPath) as! OrderManagementTableViewCell
                let cell1 = cell as! OrderManagementTableViewCell
                let order = orderList[indexPath.row]
                cell1.label1.text = order["time"].string
                cell1.label2.text = order["fromAddress"].string
                cell1.label3.text = order["toAddress"].string
                if let toAddress = order["toAddress"].string where !toAddress.isEmpty {
                    cell1.icon3Height.constant = 20
                    cell1.label3TopSpace.constant = 8
                } else {
                    cell1.icon3Height.constant = 0
                    cell1.label3TopSpace.constant = 0
                }
                var passenger = order["otherPassenger"].string
                if passenger == nil || passenger!.isEmpty {
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    if let phoneNumber = userDefault.stringForKey(Constant.KeyForPhoneNumber) {
                        passenger = "本人（\(phoneNumber)）"
                    }
                }
                cell1.label4.text = passenger
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row
        if tableView == menuTableView {
            
            titleBtnAction(titleBtn)
            selectedMenuItemIndex = row
            
        } else {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("OrderDetailViewController") as! OrderDetailViewController
            let order = orderList[indexPath.row]
            vc.orderId = order["id"].int
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if orderList.count != 0 && indexPath.row == orderList.count-1 {
            loadMoreData()
        }
    }
    
    func titleBtnAction(sender: UIButton) {
        
        titleBtn.selected = !titleBtn.selected
        titleBtn.selected ? showMenu() : hideMenu()
    }
    
    func showMenu() {
        
        let constraintAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        let alphaAnim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        constraintAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        alphaAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        constraintAnim.fromValue = menuTopSpaceConstant.constant
        constraintAnim.toValue = 0
        
        alphaAnim.fromValue = 0
        alphaAnim.toValue = 0.3
        
        menuTopSpaceConstant.pop_addAnimation(constraintAnim, forKey: "menuShow")
        dimmingView.pop_addAnimation(alphaAnim, forKey: "bgAlphaNonZero")
        
        titleBtnImg.image = UIImage(named: "IconArrowUp")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    func hideMenu() {
        
        let constraintAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        let alphaAnim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        constraintAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        alphaAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        constraintAnim.fromValue = menuTopSpaceConstant.constant
        constraintAnim.toValue = -menuTableView.frame.size.height
        
        alphaAnim.fromValue = 0.3
        alphaAnim.toValue = 0
        
        menuTopSpaceConstant.pop_addAnimation(constraintAnim, forKey: "menuHide")
        dimmingView.pop_addAnimation(alphaAnim, forKey: "bgAlphaZero")
        
        titleBtnImg.image = UIImage(named: "IconArrowDown")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    func onTapDimmingView() {
        if menuTopSpaceConstant.constant == 0 {
            
            titleBtnAction(titleBtn)
        }
    }
    
    //弹出评价窗口
    var popupVC: STPopupController!
    func popupRatingController(sender: UIButton) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("RatingViewController") as! RatingViewController
        vc.dataDict = orderList[sender.tag].dictionaryObject
        vc.dataDict["indexInList"] = sender.tag
        vc.title = "订单评分"
        let width = UIApplication.sharedApplication().keyWindow?.frame.size.width
        vc.contentSizeInPopup = CGSizeMake(width!, 300)
        vc.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        
        popupVC = STPopupController(rootViewController: vc)
        popupVC.style = .BottomSheet
        popupVC.presentInViewController(self)
        popupVC.backgroundView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPopupControllerBackground(_:))))
    }
    
    func onTapPopupControllerBackground(sender: UITapGestureRecognizer) {
        popupVC.dismiss()
    }
    
    func evaluateOrder(notification: NSNotification) {
        
        guard let dataDict = notification.userInfo else {
            return
        }
        let orderId = dataDict["id"] as! Int
        let grade = dataDict["grade"] as! Int
        let indexInList = dataDict["indexInList"] as! Int
        
        URLConnector.request(Router.evaluateOrder(orderId: "\(orderId)", grade: "\(grade)"), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    self.orderEvaluateStatusDict[self.orderList[indexInList]["id"].int!] = status
                    self.orderTableView.reloadData()
                } else {
                    UITools.sharedInstance.toast("评价订单失败，请重试")
                }
            }
        })
    }
    
    func getOrderEvaluationStatus(indexInList: Int) {
        
        let orderId = orderList[indexInList]["id"].int
        
        URLConnector.request(Router.isOrderEvaluated(orderId: "\(orderId)"), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    self.orderEvaluateStatusDict[self.orderList[indexInList]["id"].int!] = status
                    self.orderTableView.reloadData()
                } else {
                    
                }
            }
        })
    }
    
    func getOrdersByStatus(isLoadMore: Bool) {
        
        URLConnector.request(Router.getOrdersByStatus(orderStatus: orderStatus[selectedMenuItemIndex], pageNum: "\(currentPage)"), successCallBack: { value in
            if let page = value.dictionary {
                self.currentPage = page["currentPage"]!.int!
                self.pageCount = page["pageCount"]!.int!
                if let list = page["recordList"]?.array {
                    if isLoadMore {
                        self.orderList.appendContentsOf(list)
                    } else {
                        self.orderList = list
                    }
                    self.orderTableView.mj_header.endRefreshing()
                    self.orderTableView.reloadData()
                    
                    print("self.orderList.count:\(self.orderList.count)")
                    self.orderList.count == 0 ? self.showTipForNoData() : UITools.sharedInstance.hideNoDataTipFromView(self.orderTableView)
                    
                }
                
                //如果是历史行程就获取订单是否已评分
                if self.selectedMenuItemIndex == 2 {
                    for indexInList in 0..<self.orderList.count {
                        self.getOrderEvaluationStatus(indexInList)
                    }
                }
            }
        })
    }
    
    func refreshData() {
        currentPage = 1
        getOrdersByStatus(false)
    }
    
    func loadMoreData() {
        currentPage += 1
        NSLog("load more %d", currentPage)
        if currentPage <= pageCount {
            getOrdersByStatus(true)
        } else {
            currentPage = pageCount
        }
    }
    
    func showTipForNoData() {
        switch selectedMenuItemIndex {
        case 0:
            UITools.sharedInstance.showNoDataTipToView(self.orderTableView, tipStr: "您还没有预订哦")
        case 1:
            UITools.sharedInstance.showNoDataTipToView(self.orderTableView, tipStr: "您的行程还没有开始哦")
        case 2:
            UITools.sharedInstance.showNoDataTipToView(self.orderTableView, tipStr: "还没有已完成的行程哦")
        case 3:
            UITools.sharedInstance.showNoDataTipToView(self.orderTableView, tipStr: "并没有取消的行程")

        default:
            break
        }
    }
}

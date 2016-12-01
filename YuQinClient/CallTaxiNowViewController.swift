//
//  CallTaxiNowViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/18.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import STPopup
import Alamofire

class CallTaxiNowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellIdentifierForCustomerInfo = "CellForCustomerInfo"
    let cellIdentifierForSelectAddress = "CellForSelectAddress"
    let cellIdentifierForSelectDate = "CellForSelectDate"
    let cellIdentifierForSelectCarType = "CellForSelectCarType"

    @IBOutlet weak var tableView: UITableView!
    var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: BottomUIView!
    
    var customerPhoneLabel: UILabel!
    var dateLabel: UILabel!
    var startAddressCityLabel: UILabel!
    var endAddressCityLabel: UILabel!
    var startAddressLabel: UILabel!
    var endAddressLabel: UILabel!
    var tableFooterView: ChargeAndCarInfoUIView!
    
    var dateFormatter = NSDateFormatter()
    
    var carTypeList = [Dictionary<String, AnyObject>]()
    var selectedCustomerInfo = CustomerInfo()
    var fromAddress: BMKPoiInfo?
    var toAddress: BMKPoiInfo?
    
    //选中的车型
    var selectedCarType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //去掉顶部空白
        self.automaticallyAdjustsScrollViewInsets = false
        
        dateFormatter.dateFormat = "MM月dd日 HH:mm E"
        
        bottomView.setContentViewFrame(self.bottomView.frame)
        bottomView.submitBtn.addTarget(self, action: #selector(submitOrder(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        //为表视图注册类
        tableView.registerClass(CustomerInfoTableViewCell.self, forCellReuseIdentifier: cellIdentifierForCustomerInfo)
        tableView.registerClass(SelectAddressTableViewCell.self, forCellReuseIdentifier: cellIdentifierForSelectAddress)
        tableView.registerClass(SelectDateTableViewCell.self, forCellReuseIdentifier: cellIdentifierForSelectDate)
        tableView.registerClass(SelectCarTypeTableViewCell.self, forCellReuseIdentifier: cellIdentifierForSelectCarType)
        
        //为表视图注册Nib
        let cellNib1 = UINib(nibName: "CustomerInfoTableViewCell", bundle: nil)
        tableView.registerNib(cellNib1, forCellReuseIdentifier: cellIdentifierForCustomerInfo)
        let cellNib2 = UINib(nibName: "SelectAddressTableViewCell", bundle: nil)
        tableView.registerNib(cellNib2, forCellReuseIdentifier: cellIdentifierForSelectAddress)
        let cellNib3 = UINib(nibName: "SelectDateTableViewCell", bundle: nil)
        tableView.registerNib(cellNib3, forCellReuseIdentifier: cellIdentifierForSelectDate)
        let cellNib4 = UINib(nibName: "SelectCarTypeTableViewCell", bundle: nil)
        tableView.registerNib(cellNib4, forCellReuseIdentifier: cellIdentifierForSelectCarType)
        
        //设置tableView Footer
        tableFooterView = ChargeAndCarInfoUIView.loadFromNib() as! ChargeAndCarInfoUIView
        tableView.tableFooterView = tableFooterView
        tableFooterView.label1.text = ""
        tableFooterView.label2.text = ""
        tableFooterView.label3.text = ""
        
        //设置tableView背景色
//        tableView.backgroundView = nil
//        tableView.backgroundColor = UIColor.clearColor()
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectCustomer(_:)), name: Constant.CallTaxiNowViewControllerDidSelectCustomerNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectStartAddress(_:)), name: Constant.CallTaxiNowViewControllerDidSelectStartAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectEndAddress(_:)), name: Constant.CallTaxiNowViewControllerDidSelectEndAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectFavStartAddress(_:)), name: Constant.CallTaxiNowViewControllerDidSelectFavStartAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectFavEndAddress(_:)), name: Constant.CallTaxiNowViewControllerDidSelectFavEndAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didGetCustomerInfo(_:)), name: Constant.DidGetCustomerInfoNofification, object: nil)
        //网络变化通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        
        //bottomView添加点击事件
        let bottomViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickBottomView(_:)))
        bottomView.addGestureRecognizer(bottomViewTapGesture)
        
        setCustomerInfo()
        
        getAllCarServiceType()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK - tableview delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForCustomerInfo, forIndexPath: indexPath)
            cell.accessoryType = .DisclosureIndicator
            let cell1 = cell as! CustomerInfoTableViewCell
            cell1.label1.text = selectedCustomerInfo.phone
            customerPhoneLabel = cell1.label1
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForSelectAddress, forIndexPath: indexPath)
            let cell1 = cell as! SelectAddressTableViewCell
            cell1.button.tag = row
            cell1.button.addTarget(self, action: #selector(popupSelectFavoriteAddressController(_:)), forControlEvents: .TouchUpInside)
            if row == 0 {
                startAddressCityLabel = cell1.label1
                startAddressLabel = cell1.label2
                startAddressLabel.text = fromAddress != nil ? fromAddress?.name : "请选择上车地点"
            } else {
                endAddressCityLabel = cell1.label1
                endAddressLabel = cell1.label2
                endAddressLabel.text = toAddress != nil ? toAddress?.name : "请选择下车地点"
            }
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForSelectCarType, forIndexPath: indexPath)
            let cell1 = cell as! SelectCarTypeTableViewCell
            collectionView = cell1.collectionView
            cell1.collectionView.dataSource = self
            cell1.collectionView.delegate = self
            cell1.collectionView.reloadData()

        default:
            print("no match")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 2 {
            return Constant.CollectionViewHeight
        } else {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            let page2 = storyboard?.instantiateViewControllerWithIdentifier("CallTaxiForOtherViewController") as! CallTaxiForOtherViewController
            page2.identifier = Constant.CallTaxiNowViewControllerDidSelectCustomerNofification
            page2.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(page2, animated: true)
            break
        case 1:
            let page2 = storyboard?.instantiateViewControllerWithIdentifier("SelectAddressViewController") as! SelectAddressViewController
            if row == 0 {
                page2.identifier = Constant.CallTaxiNowViewControllerDidSelectStartAddressNofification
            } else {
                page2.identifier = Constant.CallTaxiNowViewControllerDidSelectEndAddressNofification
            }
            self.navigationController?.pushViewController(page2, animated: true)
        case 2:
            break
        default:
            print("no match")
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK - collectionView delegate
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carTypeList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCellForCar", forIndexPath: indexPath) as! CarTypeCollectionViewCell
        let row = indexPath.row
        let dict = carTypeList[row]
        cell.label.text = dict["name"] as? String
        cell.imageView1.image = dict["image"] as? UIImage
        
        if selectedCarType == row {
            
            cell.imageView2.image = UIImage(named: "Checked_Checkbox")
        } else {
            cell.imageView2.image = UIImage(named: "Unchecked_Checkbox")
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(Constant.CollectionCellViewWidth, Constant.CollectionCellViewHeight)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSLog("click item %d", indexPath.row)
        selectedCarType = indexPath.row
        tableFooterView.label1.text = self.carTypeList[selectedCarType]["priceDescription"] as? String
        collectionView.reloadData()
        
        if fromAddress != nil && toAddress != nil {
            estimatePrice()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsZero
//    }
    
    //选择日期
    func selectDate() {
        let datePicker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.DateAndTime, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            let dateStr = self.dateFormatter.stringFromDate(value as! NSDate)
            self.dateLabel.text = dateStr
            
            }, cancelBlock: {ActionStringCancelBlock in return}, origin: self.view)
        datePicker.tapDismissAction = TapAction.Cancel
        datePicker.setCancelButton(UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: nil, action: nil))
        datePicker.setDoneButton(UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: nil, action: nil))
        datePicker.showActionSheetPicker()
    }
    
    func didSelectCustomer(notification: NSNotification) {
        selectedCustomerInfo = notification.object as! CustomerInfo
        customerPhoneLabel.text = selectedCustomerInfo.phone
    }
    
    func didSelectStartAddress(notification: NSNotification) {
        fromAddress = notification.object as? BMKPoiInfo
        startAddressCityLabel.text = fromAddress!.city.substringToIndex((fromAddress!.city.endIndex.advancedBy(-1)))
        startAddressLabel.text = fromAddress!.name
        startAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        startAddressLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if toAddress != nil {
            estimatePrice()
        }
    }
    
    func didSelectEndAddress(notification: NSNotification) {
        toAddress = notification.object as? BMKPoiInfo
        endAddressCityLabel.text = toAddress!.city.substringToIndex(toAddress!.city.endIndex.advancedBy(-1))
        endAddressLabel.text = toAddress!.name
        endAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        endAddressLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if fromAddress != nil {
            estimatePrice()
        }
    }
    
    func didSelectFavStartAddress(notification: NSNotification) {
        fromAddress = notification.object as? BMKPoiInfo
//        startAddressCityLabel.text = fromAddress!.city.substringToIndex((fromAddress!.city.endIndex.advancedBy(-1)))
        startAddressLabel.text = fromAddress!.name
        startAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        startAddressLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if toAddress != nil {
            estimatePrice()
        }
    }
    
    func didSelectFavEndAddress(notification: NSNotification) {
        toAddress = notification.object as? BMKPoiInfo
//        endAddressCityLabel.text = toAddress!.city.substringToIndex(toAddress!.city.endIndex.advancedBy(-1))
        endAddressLabel.text = toAddress!.name
        endAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        endAddressLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if fromAddress != nil {
            estimatePrice()
        }
    }
    
    func didGetCustomerInfo(notification: NSNotification) {
        
        selectedCustomerInfo.name = NSUserDefaults.standardUserDefaults().stringForKey(Constant.KeyForCustomerName)! ?? ""
    }
    
    //提交订到
    func submitOrder(sender: UIButton) {
        submitOrder()
    }
    
    //响应bottomView点击事件
    func onClickBottomView(sender: UITapGestureRecognizer) {
        print("onClickBottomView")
    }
    
    //弹出选择收藏地址窗口
    var popupVC: STPopupController!
    func popupSelectFavoriteAddressController(sender: UIButton) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("SelectFavoriteAddressViewController") as! SelectFavoriteAddressViewController
        if sender.tag == 0 {
            vc.identifier = Constant.CallTaxiNowViewControllerDidSelectFavStartAddressNofification
        } else {
            vc.identifier = Constant.CallTaxiNowViewControllerDidSelectFavEndAddressNofification
        }
        vc.title = "请选择常用地址"
        let width = UIApplication.sharedApplication().keyWindow?.frame.size.width
        vc.contentSizeInPopup = CGSizeMake(width!, 300)
        vc.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        
        popupVC = STPopupController(rootViewController: vc)
        popupVC.style = .BottomSheet
        popupVC.presentInViewController(self)
        popupVC.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPopupControllerBackground(_:))))
    }
    
    func onTapPopupControllerBackground(sender: UITapGestureRecognizer) {

        popupVC.dismiss()
    }
    
    func getAllCarServiceType() {
        
        if let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty {
            
            //url和参数
            let url = Constant.HOST_PATH + "/OrderApp_getAllCarServiceType.action"
            let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode]
            
            Alamofire.request(.GET, url, parameters: parameters)
                .responseJSON { response in
                    
                    switch (response.result) {
                    case .Success(let value):
                        print("get all car service type result: \(value)")
                        
                        if let list = value as? [Dictionary<String, AnyObject>] {
                            self.carTypeList = list
                            self.collectionView.reloadData()
                            self.tableFooterView.label1.text = self.carTypeList[self.selectedCarType]["priceDescription"] as? String
                        }
                        for item in self.carTypeList {
                            self.getCarImg(item["id"] as! Int)
                        }
                        
                    case .Failure(let error):
                        NSLog("Error: %@", error)
                    }
            }
        } else {
//            Tools.sharedInstance.logout(withToast: true)
        }
    }
    
    func getCarImg(type: Int) {
        
        if let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty {
            
            //url和参数
            let url = Constant.HOST_PATH + "/OrderApp_getCarServiceTypeImage.action"
            let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode, "carServiceTypeId" : type]
            
            Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
                .responseData { response in
                    
                    switch (response.result) {
                    case .Success(let value):
                        
                        for i in 0..<self.carTypeList.count {
                            if self.carTypeList[i]["id"] as! Int == type {
                                self.carTypeList[i]["image"] = UIImage(data: value)
                                break
                            }
                        }
                        self.collectionView.reloadData()
                        
                    case .Failure(let error):
                        NSLog("Error: %@", error)
                    }
            }
        } else {
//            Tools.sharedInstance.logout(withToast: true)
        }
    }
    
    func estimatePrice() {
        
        if fromAddress == nil || toAddress == nil {
            return
        }
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        
        //url和参数
        let beginTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        let url = Constant.HOST_PATH + "/OrderApp_calculatePrice.action"
        let parameters = ["phoneNumber"                     : phoneNumber,
                          "validationCode"                  : validationCode,
                          "carServiceTypeId"                : selectedCarType + 1,
                          "dayOrder"                        : "false",
                          "beginTime"                       : "\(beginTime)",
                          "endTime"                         : "",
                          "beginAddress"                    : fromAddress!.name,
                          "beginAddressDetail"              : fromAddress!.address,
                          "beginAddressLocationLongitude"   : fromAddress!.pt.longitude,
                          "beginAddressLocationLatitude"    : fromAddress!.pt.latitude,
                          "endAddress"                      : toAddress!.name,
                          "endAddressDetail"                : toAddress!.address,
                          "endAddressLocationLongitude"     : toAddress!.pt.longitude,
                          "endAddressLocationLatitude"      : toAddress!.pt.latitude]
        
        Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                print("estimate price request: \(response.request)")
                print("estimate price result: \(response.result)")
                switch (response.result) {
                case .Success(let value):
                    print("estimate price result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let dict = value as? Dictionary<String, AnyObject> {
                        
                        if let price = dict["price"] as? Int, quantity = dict["quantity"] as? Int {
                            self.bottomView.estimatedCostLabel.text = "¥\(price)（\(quantity)公里）"
                        }
                    }
                    
                    break
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }
    
    func submitOrder() {
        
        if fromAddress == nil {
            UITools.sharedInstance.shakeView(startAddressLabel)
            return
        }
        if toAddress == nil {
            UITools.sharedInstance.shakeView(endAddressLabel)
            return
        }
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            Tools.sharedInstance.logout(self.storyboard!, withToast: true)
            return
        }
        //是否为他人叫车
        let callForOther = phoneNumber != selectedCustomerInfo.phone ? "true" : "false"
        
        //等待动画
        let HUD = UITools.sharedInstance.showLoadingAnimation()
        //url和参数
        let beginTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        let url = Constant.HOST_PATH + "/OrderApp_submitOrder.action"
        let parameters = ["phoneNumber"                     : phoneNumber,
                          "validationCode"                  : validationCode,
                          "carServiceTypeId"                : selectedCarType + 1,
                          "dayOrder"                        : "false",
                          "beginTime"                       : "\(beginTime)",
                          "endTime"                         : "",
                          "beginAddress"                    : fromAddress!.name,
                          "beginAddressDetail"              : fromAddress!.address,
                          "beginAddressLocationLongitude"   : fromAddress!.pt.longitude,
                          "beginAddressLocationLatitude"    : fromAddress!.pt.latitude,
                          "endAddress"                      : toAddress!.name,
                          "endAddressDetail"                : toAddress!.address,
                          "endAddressLocationLongitude"     : toAddress!.pt.longitude,
                          "endAddressLocationLatitude"      : toAddress!.pt.latitude,
                          "callForOther"                    : callForOther,
                          "callForOtherName"                : selectedCustomerInfo.name,
                          "callForOtherPhoneNumber"         : selectedCustomerInfo.phone,
                          "callForOtherSendSMS"             : selectedCustomerInfo.sendSMS ? "true" : "false"]
        
        Alamofire.request(.GET, url, parameters: parameters as? [String : AnyObject])
            .responseJSON { response in
                print("submit order request: \(response.request)")
                //取消等待动画
                HUD.hide(true)
                
                switch (response.result) {
                case .Success(let value):
                    print("submit order result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let status = value["status"] as? Bool {
                        
                        if status {
                            UITools.sharedInstance.showAlertForSubmitOrderSuccess()
                            self.resetData()
                        } else {
                            UITools.sharedInstance.toast("订单提交失败，请重试")
                        }
                    }
                    break
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }
    
    func reachabilityChanged(notification: NSNotification) {
        
        if let curReach = notification.object as? Reachability {
            updateInterfaceWithReachability(curReach)
        }
    }
    
    func updateInterfaceWithReachability(reachability: Reachability) {
        let netStatus = reachability.currentReachabilityStatus()
        switch(netStatus) {
        case NotReachable:
            break
        case ReachableViaWiFi, ReachableViaWWAN:
            getAllCarServiceType()
        default:
            break
        }
    }
    
    func setCustomerInfo() {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let phone = userDefault.stringForKey(Constant.KeyForPhoneNumber) {
            selectedCustomerInfo.phone = phone
        }
        if let name = userDefault.stringForKey(Constant.KeyForCustomerName) {
            selectedCustomerInfo.name = name
        }
    }
    
    func resetData() {
        
        setCustomerInfo()
        
        fromAddress = nil
        toAddress = nil
        
        tableView.reloadData()
        
        self.bottomView.estimatedCostLabel.text = ""
    }

}

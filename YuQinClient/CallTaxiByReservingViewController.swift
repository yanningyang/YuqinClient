//
//  CallTaxiByReservingViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/18.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import STPopup
import Alamofire
import SwiftyJSON

class CallTaxiByReservingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    var startAddressText: UITextField!
    var endAddressText: UITextField!
    var tableFooterView: ChargeAndCarInfoUIView!
    
    
    var dateFormatter = { NSDateFormatter() }()
    
    var carTypeList: [JSON] = { [JSON]() }()
    var carTypeImgDict: [Int : UIImage] = { [Int : UIImage]() }()
    var selectedCustomerInfo = { CustomerInfo() }()
    var fromAddress: AddressInfo?
    var toAddress: AddressInfo?
    var beginDate: NSDate?
    
    //选中的车型
    var selectedCarType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        
        setCustomerInfo()
        
        getAllCarServiceType()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI() {
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectCustomer(_:)), name: Constant.CallTaxiByReservingViewControllerDidSelectCustomerNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectStartAddress(_:)), name: Constant.CallTaxiByReservingViewControllerDidSelectStartAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectEndAddress(_:)), name: Constant.CallTaxiByReservingViewControllerDidSelectEndAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectFavStartAddress(_:)), name: Constant.CallTaxiByReservingViewControllerDidSelectFavStartAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSelectFavEndAddress(_:)), name: Constant.CallTaxiByReservingViewControllerDidSelectFavEndAddressNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didGetCustomerInfo(_:)), name: Constant.DidGetCustomerInfoNofification, object: nil)
        //网络变化通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        
        //bottomView添加点击事件
        let bottomViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickBottomView(_:)))
        bottomView.addGestureRecognizer(bottomViewTapGesture)
        
        // 点击TableView关闭键盘
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapRecognizer)
        // 滑动TableView关闭键盘
        self.tableView.keyboardDismissMode = .OnDrag
    }
    
    // MARK - tableview delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 2
        } else if section == 3 {
            return 1
        } else if section == 4 {
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
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForSelectDate, forIndexPath: indexPath)
            cell.accessoryType = .DisclosureIndicator
            let cell1 = cell as! SelectDateTableViewCell
            dateLabel = cell1.dateLabel
            dateLabel.text = beginDate != nil ? dateFormatter.stringFromDate(beginDate!) : "请选择开始时间"
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForSelectAddress, forIndexPath: indexPath)
            let cell1 = cell as! SelectAddressTableViewCell
            cell1.button.tag = row
            cell1.button.addTarget(self, action: #selector(popupSelectFavoriteAddressController(_:)), forControlEvents: .TouchUpInside)
            if row == 0 {
                startAddressCityLabel = cell1.label1
                startAddressText = cell1.textField
                if fromAddress != nil {
                    startAddressText.text = fromAddress!.name
                } else {
                    startAddressText.placeholder = "请填写上车地点"
                }
            } else {
                endAddressCityLabel = cell1.label1
                endAddressText = cell1.textField
                if toAddress != nil {
                    endAddressText.text = toAddress!.name
                } else {
                    endAddressText.placeholder = "请填写下车地点"
                }
            }
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForSelectCarType, forIndexPath: indexPath)
            let cell1 = cell as! SelectCarTypeTableViewCell
            collectionView = cell1.collectionView
            collectionView.keyboardDismissMode = .OnDrag
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
        if section == 3 {
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
        switch section {
        case 0:
            let page2 = storyboard?.instantiateViewControllerWithIdentifier("CallTaxiForOtherViewController") as! CallTaxiForOtherViewController
            page2.identifier = Constant.CallTaxiByReservingViewControllerDidSelectCustomerNofification
            page2.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(page2, animated: true)
            break
        case 1:
            selectDate()
        case 2:
            break
//            let page2 = storyboard?.instantiateViewControllerWithIdentifier("SelectAddressViewController") as! SelectAddressViewController
//            if row == 0 {
//                page2.identifier = Constant.CallTaxiByReservingViewControllerDidSelectStartAddressNofification
//            } else {
//                page2.identifier = Constant.CallTaxiByReservingViewControllerDidSelectEndAddressNofification
//            }
//            self.navigationController?.pushViewController(page2, animated: true)
        case 3:
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
        cell.label.text = dict["name"].string
//        cell.imageView1.image = carTypeImgDict[dict["id"].int!]
        
        if selectedCarType == indexPath.row {
            
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
        tableFooterView.label1.text = self.carTypeList[selectedCarType]["priceDescription"].string
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
    
    //选择日期
    func selectDate() {
        let datePicker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.DateAndTime, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            let beginDate = value as? NSDate
            if beginDate?.compare(NSDate()) == .OrderedAscending {
                
                UITools.sharedInstance.toast(toView: self.view, labelText: "开始时间不能小于当前时间")
                return
            }
            self.beginDate = beginDate
            let dateStr = self.dateFormatter.stringFromDate(self.beginDate!)
            self.dateLabel.text = dateStr
            
            }, cancelBlock: {ActionStringCancelBlock in return}, origin: self.view)
        datePicker.tapDismissAction = TapAction.Cancel
        datePicker.setCancelButton(UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: nil, action: nil))
        datePicker.setDoneButton(UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: nil, action: nil))
        datePicker.minimumDate = NSDate().dateByAddingTimeInterval(10 * 60)
        datePicker.minuteInterval = 10
        datePicker.showActionSheetPicker()
    }
    
    func didSelectCustomer(notification: NSNotification) {
        selectedCustomerInfo = notification.object as! CustomerInfo
        customerPhoneLabel.text = selectedCustomerInfo.phone
    }
    
    func didSelectStartAddress(notification: NSNotification) {
        fromAddress = notification.object as? AddressInfo
//        startAddressCityLabel.text = fromAddress!.city.substringToIndex((fromAddress!.city.endIndex.advancedBy(-1)))
        startAddressText.text = fromAddress!.description
//        startAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        startAddressText.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if toAddress != nil {
            estimatePrice()
        }
    }
    
    func didSelectEndAddress(notification: NSNotification) {
        toAddress = notification.object as? AddressInfo
//        endAddressCityLabel.text = toAddress!.city.substringToIndex(toAddress!.city.endIndex.advancedBy(-1))
        endAddressText.text = toAddress!.description
//        endAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        endAddressText.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if fromAddress != nil {
            estimatePrice()
        }
    }
    
    func didSelectFavStartAddress(notification: NSNotification) {
        fromAddress = notification.object as? AddressInfo
        //        startAddressCityLabel.text = fromAddress!.city.substringToIndex((fromAddress!.city.endIndex.advancedBy(-1)))
        startAddressText.text = fromAddress!.description
//        startAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        startAddressText.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if toAddress != nil {
            estimatePrice()
        }
    }
    
    func didSelectFavEndAddress(notification: NSNotification) {
        toAddress = notification.object as? AddressInfo
        //        endAddressCityLabel.text = toAddress!.city.substringToIndex(toAddress!.city.endIndex.advancedBy(-1))
        endAddressText.text = toAddress!.description
//        endAddressCityLabel.textColor = UITools.sharedInstance.getDefaultTextColor()
        endAddressText.textColor = UITools.sharedInstance.getDefaultTextColor()
        
        if fromAddress != nil {
            estimatePrice()
        }
    }
    
    func didGetCustomerInfo(notification: NSNotification) {
        
        selectedCustomerInfo.name = NSUserDefaults.standardUserDefaults().stringForKey(Constant.KeyForCustomerName)! ?? ""
    }
    
    //提交订单
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
            vc.identifier = Constant.CallTaxiByReservingViewControllerDidSelectFavStartAddressNofification
        } else {
            vc.identifier = Constant.CallTaxiByReservingViewControllerDidSelectFavEndAddressNofification
        }
        vc.title = "请选择常用地址"
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
    
    func getAllCarServiceType() {
        
        URLConnector.request(Router.getAllCarServiceType, successCallBack: { value in
            
            if let list = value.array {
                self.carTypeList = list
                self.collectionView.reloadData()
                self.tableFooterView.label1.text = self.carTypeList[self.selectedCarType]["priceDescription"].string
            }
//            for item in self.carTypeList {
//                self.getCarImg(item["id"].int!)
//            }
        })
    }
    
    func getCarImg(type: Int) {
        
        // 先查看内存中是否存在
        if self.carTypeImgDict[type] != nil { return }
        
        // 再看磁盘中是否存在
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let localFileName = "carType_\(type).jpg"
        guard let fileURL = documentsURL.URLByAppendingPathComponent(localFileName), filePath = fileURL.path else {
            return
        }
        let fileExists = NSFileManager.defaultManager().fileExistsAtPath(filePath)
        if fileExists {
            self.carTypeImgDict[type] = UIImage(contentsOfFile: filePath)
            return
        }
        
        // 最后访问网络
        URLConnector.download(Router.getCarServiceTypeImage(carServiceTypeId: "\(type)"), localFileName: localFileName, downloadComplete: { success, destinationURL in
            self.carTypeImgDict[type] = UIImage(contentsOfFile: filePath)
        })
    }
    
    func estimatePrice() {
        
    }
    
    func submitOrder() {
        
        if beginDate == nil{
            UITools.sharedInstance.shakeView(dateLabel)
            return
        }
        guard let fromAddressStr = startAddressText.text where !fromAddressStr.isEmpty else {
            UITools.sharedInstance.shakeView(startAddressText)
            return
        }
        guard let toAddressStr = endAddressText.text where !toAddressStr.isEmpty else {
            UITools.sharedInstance.shakeView(endAddressText)
            return
        }
        if beginDate!.compare(NSDate()) == .OrderedAscending {
            UITools.sharedInstance.toast(toView: self.view, labelText: "开始时间不能小于当前时间")
            return
        }
        
        let userInfo = Util.sharedInstance.getUserInfo()
        guard let phoneNumber = userInfo.0, validationCode = userInfo.1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            print("从本地获取登录信息失败!")
            return
        }
        //是否为他人叫车
        let callForOther = phoneNumber != selectedCustomerInfo.phone ? "true" : "false"
        let beginTime = Int64(beginDate!.timeIntervalSince1970 * 1000)
        let parameters = ["carServiceTypeId"                : "\(selectedCarType+1)",
                          "chargeMode"                      : "\(OrderType.mile)",
                          "beginTime"                       : "\(beginTime)",
                          "endTime"                         : "",
                          "beginAddress"                    : fromAddressStr,
                          "endAddress"                      : toAddressStr,
                          "callForOther"                    : callForOther,
                          "callForOtherName"                : selectedCustomerInfo.name,
                          "callForOtherPhoneNumber"         : selectedCustomerInfo.phone,
                          "callForOtherSendSMS"             : selectedCustomerInfo.sendSMS ? "true" : "false"]
        URLConnector.request(Router.submitOrder(params: parameters), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    UITools.sharedInstance.showAlertForSubmitOrderSuccess()
                    self.resetData()
                } else {
                    UITools.sharedInstance.toast("订单提交失败，请重试")
                }
            }
        })
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
        beginDate = nil
        
        tableView.reloadData()
        
        self.bottomView.estimatedCostLabel.text = ""
    }
    
    //MARK: - Gesture handle
    func onTapBackgroundView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

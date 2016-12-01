//
//  SelectAddressViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/17.
//  Copyright © 2016年 YuQin. All rights reserved.
//
/*
import UIKit
import pop

class SelectAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, BMKSuggestionSearchDelegate {
    
    var identifier: String!

    @IBOutlet weak var _mapView: BMKMapView!
    
    @IBOutlet weak var cityNameBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatiorView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var topLayout: UIView!
    @IBOutlet weak var tableViewConstraintTop: NSLayoutConstraint!
    
    var oldTableViewConstraintTopConstant: CGFloat!
    
    var _locService: BMKLocationService?
    
    var _geocodeSearch: BMKGeoCodeSearch!
    
    var poiList = [BMKPoiInfo]()
    
    var _poiSearch: BMKPoiSearch!
    var currPageIndex: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        //定位
        _locService = BMKLocationService()
        
        _mapView.zoomLevel = 18
        
        //地理编码搜索
        _geocodeSearch = BMKGeoCodeSearch()
        //搜索
        _poiSearch = BMKPoiSearch()
        
        //实时检索
        searchTextField.addTarget(self, action: #selector(sendPoiSearchRequest), forControlEvents: .EditingChanged)
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SelectAddressViewController.didSelectCity(_:)), name: Constant.DidSelectCityNofification, object: nil)
        
        let backBarBtnItem = UIBarButtonItem()
        backBarBtnItem.title = ""
        self.navigationItem.backBarButtonItem = backBarBtnItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        _mapView.delegate = self
        _locService?.delegate = self
        _geocodeSearch.delegate = self
        _poiSearch.delegate = self
        startLocation()
        _mapView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopLocation()
        _locService?.delegate = nil
        _mapView.delegate = nil
        _geocodeSearch.delegate = nil
        _poiSearch.delegate = nil
        _mapView.viewWillDisappear()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        oldTableViewConstraintTopConstant = tableViewConstraintTop.constant
        print(tableViewConstraintTop.constant)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func geoSearch() {
        let geocodeSearchOption = BMKGeoCodeSearchOption()
        geocodeSearchOption.city = cityNameBtn.titleLabel?.text
        geocodeSearchOption.address = cityNameBtn.titleLabel?.text
        let flag = _geocodeSearch.geoCode(geocodeSearchOption)
        if flag {
            print("geo 检索发送成功")
        } else {
            print("geo 检索发送失败")
        }
    }
    
    func reverseGeoSearch() {
        let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
        reverseGeocodeSearchOption.reverseGeoPoint = _mapView.centerCoordinate
        let flag = _geocodeSearch.reverseGeoCode(reverseGeocodeSearchOption)
        if flag {
            print("反geo 检索发送成功")
        } else {
            print("反geo 检索发送失败")
        }
    }
    
    func sendPoiSearchRequest() {
        let citySearchOption = BMKCitySearchOption()
        citySearchOption.pageIndex = currPageIndex
        citySearchOption.pageCapacity = 10
        citySearchOption.city = cityNameBtn.titleLabel?.text
        citySearchOption.keyword = searchTextField.text
        if _poiSearch.poiSearchInCity(citySearchOption) {
            print("城市内检索发送成功！")
        }else {
            print("城市内检索发送失败！")
        }
    }
    
    func startLocation() {
        
        NSLog("进入普通定位态");
        _locService?.startUserLocationService()
        
        //不显示定位图层
        _mapView?.showsUserLocation = false
        _mapView?.userTrackingMode = BMKUserTrackingModeNone
        
        let imgPath = Tools.sharedInstance.getBaiduMapBundlePath("images/pin_red.png")
        if imgPath != nil {
            indicatiorView.image = UIImage(contentsOfFile: imgPath!)
        }
    }
    
    func stopLocation() {
        _locService?.stopUserLocationService()
        _mapView.showsUserLocation = false
    }
    
    // MARK: - Action
    
    @IBAction func locationFoucusAction(sender: UIButton) {
        
        startLocation()
    }
    @IBAction func selectCityBtnAction(sender: UIButton) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("SelectCityViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCellForSelectAddress", forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        let poi = poiList[row]
        cell.textLabel?.text = poi.name
        cell.detailTextLabel?.text = poi.address
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        NSNotificationCenter.defaultCenter().postNotificationName(identifier, object: poiList[indexPath.row])
        NSNotificationCenter.defaultCenter().postNotificationName(identifier, object: poiList[indexPath.row], userInfo: ["city" : (cityNameBtn.titleLabel?.text)!])
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        NSLog("tableView start scroll")
        
        searchTextField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // MARK: - BMKMapViewDelegate
    
    func mapView(mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        
        searchTextField.resignFirstResponder()
        reverseGeoSearch()
        NSLog("latitude:%f longitude:%f", _mapView.centerCoordinate.latitude, _mapView.centerCoordinate.longitude)
    }

    // MARK: - BMKLocationServiceDelegate
    
    /**
     *在地图View将要启动定位时，会调用此函数
     */
    func willStartLocatingUser() {
        NSLog("start locate")
    }
    
    /**
     *用户方向更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        
        _mapView.updateLocationData(userLocation)
    }
    
    /**
     *用户位置更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        
        _mapView.centerCoordinate = userLocation.location.coordinate
        _mapView?.updateLocationData(userLocation)
        stopLocation()
        
        NSLog("didUpdateBMKUserLocation 纬度: %f, 经度: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)
    }
    
    /**
     *在地图View停止定位后，会调用此函数
     */
    func didStopLocatingUser() {
        NSLog("stop locate")
    }
    
    /**
     *定位失败后，会调用此函数
     *@param mapView 地图View
     *@param error 错误号，参考CLError.h中定义的错误号
     */
    func didFailToLocateUserWithError(error: NSError!) {
        NSLog("location error")
    }
    
    /**
     *返回地址信息搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结BMKGeoCodeSearch果
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetGeoCodeResult error: \(error)")
        
        if error == BMK_SEARCH_NO_ERROR {
            _mapView.centerCoordinate = result.location
        }
    }
    
    /**
     *返回反地理编码搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结果
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        
        if error == BMK_SEARCH_NO_ERROR {
            
            if result != nil {
                
                print(result.address)
                
                poiList.removeAll()
                poiList = result.poiList as! [BMKPoiInfo]
                tableView.reloadData()
                
            }
        } else {
            // 各种情况的判断……
        }
    }
    
    // MARK: - BMKPoiSearchDelegate
    /**
    *返回POI搜索结果
    *@param searcher 搜索对象
    *@param poiResult 搜索结果列表
    *@param errorCode 错误号，@see BMKSearchErrorCode
    */
    func onGetPoiResult(searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        print("onGetPoiResult code: \(errorCode)");
        
        // 清除屏幕中所有的 annotation
        
        if errorCode == BMK_SEARCH_NO_ERROR {
            if let poiInfoList = poiResult.poiInfoList {
                
                poiList.removeAll()
                poiList = poiInfoList as! [BMKPoiInfo]
                
                tableView.reloadData()
            }

        } else if errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD {
            print("检索词有歧义")
        } else {
            // 各种情况的判断……
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        NSLog("开始编辑")
        print(tableViewConstraintTop.constant)
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.toValue = 0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        tableViewConstraintTop.pop_addAnimation(anim, forKey: "up")
        
        addBarRightBtn()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        searchTextField.resignFirstResponder()
        return true
    }
    
    func onClickRightBarBtn(sender: UIBarButtonItem) {
        print("right bar btn is clicked @ SelectAddressViewController")
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.toValue = oldTableViewConstraintTopConstant
//        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        tableViewConstraintTop.pop_addAnimation(anim, forKey: "down")
        
        hideBarRightBtn()
        searchTextField.resignFirstResponder()
    }
    
    //添加右上角按钮
    func addBarRightBtn() {
        
        let rightBarBtn = UIBarButtonItem(title: "显示地图", style: .Plain, target: self, action: #selector(onClickRightBarBtn(_:)))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    //取消右上角按钮
    func hideBarRightBtn() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func didSelectCity(notification: NSNotification) {
        let data = notification.object as! String
        cityNameBtn.setTitle(data, forState: .Normal)
//        sendSuggestSearchRequest()
        geoSearch()
    }
}
*/

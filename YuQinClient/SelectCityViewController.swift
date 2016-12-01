//
//  SelectCityViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/21.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

class SelectCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var indexList: [String]!
    
    var cityList = [[String]]()
    
    var dataList: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexColor = UITools.sharedInstance.getDefaultColor()
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return indexList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForCityList", forIndexPath: indexPath) as UITableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        cell.textLabel?.text = cityList[section][row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  " + indexList[section]
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidSelectCityNofification, object: cityList[indexPath.section][indexPath.row])
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexList
    }
    
    func loadData() {
        if let plistPath = NSBundle.mainBundle().pathForResource("CityList", ofType: "plist") {
            
            if let dataList = NSDictionary(contentsOfFile: plistPath) {
                
                let keys = dataList.allKeys as! [String]
                indexList = keys.sort(){ $0 < $1 }
                
                for item in indexList! {
                    cityList.append(dataList[item] as! [String])
                }
                
                print(cityList)
                tableView.reloadData()
            }
        }
    }

}

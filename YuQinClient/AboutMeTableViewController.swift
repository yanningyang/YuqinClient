//
//  AboutMeTableViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import STPopup

class AboutMeTableViewController: UITableViewController {

    @IBOutlet weak var portraitImgView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("head", ofType: "jpg")
        portraitImgView.image = UIImage(contentsOfFile: path!)
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCustomerInfo), name: Constant.DidGetCustomerInfoNofification, object: nil)
        
        Tools.sharedInstance.getCustomerInfoFromNet()
//        setCustomerInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 0 {
            return 80
        } else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        var vc: UIViewController!
        if section == 1 {
            vc = storyboard?.instantiateViewControllerWithIdentifier("OrderManagementViewController")
        } else if section == 2 {
            if row == 0 {
                vc = storyboard?.instantiateViewControllerWithIdentifier("FavAddressManagementViewController")
            } else {
                vc = storyboard?.instantiateViewControllerWithIdentifier("FavPassengersManagementViewController")
            }
        } else if section == 3 {
            //检查更新
            Tools.sharedInstance.loadAndParseUpdateInfoXML(2)
        }
        if vc != nil {
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setCustomerInfo() {
        
        let userdefault = NSUserDefaults.standardUserDefaults()
        if let customerName = userdefault.stringForKey(Constant.KeyForCustomerName) {
            usernameLabel.text = customerName
        }
        if let customerGender = userdefault.stringForKey(Constant.KeyForCustomerGender) {
            genderLabel.text = customerGender
        }
    }

}

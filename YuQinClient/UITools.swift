//
//  UITools.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import MBProgressHUD
import pop
import STPopup

public class UITools {
    
    static let sharedInstance = UITools()
    //私有化init方法，保证单例
    private init(){}
    
    //Toast
    func toast(toView view: UIView, labelText: String) {
        let toast = MBProgressHUD.showHUDAddedTo(view, animated: true)
        toast.mode = MBProgressHUDMode.Text
        toast.userInteractionEnabled = false
        toast.labelText = labelText
        toast.margin = 10.0
        toast.color = UIColor(red: 0.23, green: 0.50, blue: 0.82, alpha: 0.90)
        toast.removeFromSuperViewOnHide = true
        toast.hide(true, afterDelay: 2)
    }
    
    //Toast
    func toast(labelText: String) {
        let toast = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow!, animated: true)
        toast.mode = MBProgressHUDMode.Text
        toast.userInteractionEnabled = false
        toast.labelText = labelText
        toast.margin = 10.0
        toast.color = UIColor(red: 0.23, green: 0.50, blue: 0.82, alpha: 0.90)
        toast.removeFromSuperViewOnHide = true
        toast.hide(true, afterDelay: 2)
    }
    
    func showNoDataTipToView(view: UIView, tipStr: String) {
        //先移除
        hideNoDataTipFromView(view)
        
        let toast = MBProgressHUD.showHUDAddedTo(view.superview, animated: false)
        toast.mode = MBProgressHUDMode.Text
        toast.userInteractionEnabled = false
        toast.labelText = tipStr
        toast.labelFont = UIFont.systemFontOfSize(18.0)
        toast.labelColor = UIColor.colorWithHex(0x999999)
        toast.backgroundColor = UIColor.clearColor()
        toast.margin = 10.0
        toast.color = UIColor.clearColor()
        toast.removeFromSuperViewOnHide = true
    }
    
    func hideNoDataTipFromView(view: UIView) {
        MBProgressHUD.hideAllHUDsForView(view.superview, animated: false)
    }
    
    func showLoadingAnimationTo(view: UIView) {
        let loading = MBProgressHUD.showHUDAddedTo(view, animated: true)
        loading.userInteractionEnabled = false
        loading.labelText = ""
        loading.color = UIColor.clearColor()
        loading.activityIndicatorColor = UIColor.redColor()
        loading.customView = UIProgressView(progressViewStyle: .Default)
        loading.removeFromSuperViewOnHide = true
    }
    
    func hideLoadingAnimationFrom(view: UIView) {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
    
    //加载动画
    func showLoadingAnimation(labelText: String) ->MBProgressHUD {
        let HUD = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow!, animated: true)
        HUD.labelText = labelText
        return HUD
    }
    
    //加载动画
    func showLoadingAnimation() ->MBProgressHUD {
        let HUD = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow!, animated: true)
        HUD.labelText = "请稍候..."
        return HUD
    }
    
    //提示检查网络
    func showAlertForNoNetwork() {
        let alertController = UIAlertController(title: "提醒", message: "请检查网络设置", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "确定", style: .Default) { alertAction in
            NSLog("无网络")
        }
        alertController.addAction(ok)
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            rootViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //提示订单提交成功
    func showAlertForSubmitOrderSuccess() {
        let alertController = UIAlertController(title: "提醒", message: "订单提交成功！请保持电话畅通，司机会尽快跟你联系。", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "确定", style: .Default) { alertAction in
            NSLog("用户点击确认")
        }
        alertController.addAction(ok)
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            rootViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //收到通知跳转到详情界面
    func pushToDetailPage(userInfo: [NSObject : AnyObject]) {
        
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController!
        if rootVC is HomeViewController {
            let vc1 = rootVC as! HomeViewController
            let vc2 = rootVC.storyboard!.instantiateViewControllerWithIdentifier("OrderDetailViewController") as! OrderDetailViewController
            vc2.orderId = userInfo["orderId"] as! Int
            vc1.presentViewController(vc2, animated: true, completion: nil)
        }
    }
    
    //view抖动效果
    func shakeView(view: UIView) {
        
        let center = view.center
        let duration: CFTimeInterval = 0.1
        let offset: CGFloat = 10
        
        if let keys = view.pop_animationKeys() {
            print(keys)
            return
        }
        
        let anim1 = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        anim1.toValue = NSValue(CGPoint: CGPointMake(center.x + offset, center.y))
        anim1.beginTime = CACurrentMediaTime()
        anim1.duration = duration
        
        let anim2 = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        anim2.toValue = NSValue(CGPoint: CGPointMake(center.x - offset, center.y))
        anim1.beginTime = CACurrentMediaTime() + duration
        anim1.duration = duration
        
        let anim3 = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        anim3.toValue = NSValue(CGPoint: CGPointMake(center.x + offset, center.y))
        anim3.beginTime = CACurrentMediaTime() + 2 * duration
        anim3.duration = duration
        
        let anim4 = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        anim4.toValue = NSValue(CGPoint: CGPointMake(center.x - offset, center.y))
        anim4.beginTime = CACurrentMediaTime() + 3 * duration
        anim4.duration = duration
        
        let anim5 = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        anim5.toValue = NSValue(CGPoint: center)
        anim5.beginTime = CACurrentMediaTime() + 4 * duration
        anim5.duration = duration
        
        view.pop_addAnimation(anim1, forKey: "shake1")
        view.pop_addAnimation(anim2, forKey: "shake2")
        view.pop_addAnimation(anim3, forKey: "shake3")
        view.pop_addAnimation(anim4, forKey: "shake4")
        view.pop_addAnimation(anim5, forKey: "shake5")
        
    }
    
    func addBorderTo(button: UIButton, color: CGColor?) {
        
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5.0
        
        var cgColor: CGColor!
        cgColor = color
        if color == nil {
            let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
            cgColor = CGColorCreate(colorSpaceRef, [1, 0, 0, 1])
        }
        button.layer.borderColor = cgColor
    }
    
//    func popupSelectFavoriteAddressController(target: UIViewController) {
//        
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = target.storyboard!.instantiateViewControllerWithIdentifier("SelectFavoriteAddressViewController") as! SelectFavoriteAddressViewController
//        vc.title = "请选择常用地址"
//        let width = UIApplication.sharedApplication().keyWindow?.frame.size.width
//        vc.contentSizeInPopup = CGSizeMake(width!, 300)
//        vc.landscapeContentSizeInPopup = CGSizeMake(400, 200)
//        
//        var popupVC: STPopupController!
//        popupVC = STPopupController(rootViewController: vc)
//        popupVC.style = .BottomSheet
//        popupVC.presentInViewController(target)
//        popupVC.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: Selector("onTapPopupControllerBackground:")))
//        
//    }
//    
//    func onTapPopupControllerBackground(sender: UITapGestureRecognizer) {
//        
//        var vc: UIViewController!
//        for(var next = sender.view; next != nil; next = next?.superview) {
//            if let nextResponder = next!.nextResponder() {
//                
//                if nextResponder is UIViewController {
//                    vc = nextResponder as! UIViewController
//                    vc.dismissViewControllerAnimated(true, completion: nil)
//                }
//            }
//        }
//    }
    
    func getDefaultColor() -> UIColor {
        return UIColor(red: 34.0/255.0, green: 189.0/255.0, blue: 246.0/255.0, alpha: 1)
    }
    
    func getDefaultTextColor() -> UIColor {
        return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1)
    }
    
    func createImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage!
    }

}

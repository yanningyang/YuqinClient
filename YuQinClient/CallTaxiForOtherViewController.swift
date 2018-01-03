//
//  CallTaxiForOtherViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import AddressBookUI
import ContactsUI
import pop

class CallTaxiForOtherViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, CNContactPickerDelegate {

    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var customerPhoneNumTextField: UITextField!
    @IBOutlet weak var checkboxView: UIView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    var identifier: String!
    
    var keyboardHeight: CGFloat = 250
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //checkbox
        checkBoxBtn.setImage(UIImage(named: "Unchecked_Checkbox"), forState: UIControlState.Normal)
        checkBoxBtn.setImage(UIImage(named: "Checked_Checkbox"), forState: UIControlState.Selected)
        checkBoxBtn.addTarget(self, action: #selector(checkboxClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        checkBoxBtn.selected = true
        
        //bottomView添加点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkboxViewClick(_:)))
        checkboxView.addGestureRecognizer(tapGesture)
        
        //添加右上角按钮
        let rightBarBtn = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: #selector(onClickRightBarBtn(_:)))
        let leftBarBtn = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: #selector(onClickLeftBarBtn(_:)))
        leftBarBtn.image = UIImage(named: "BtnClose")
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        //添加触摸手势
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTouches(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @available(iOS 9.0, *)
    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
        let familyName = contactProperty.contact.familyName
        let givenName = contactProperty.contact.givenName
        self.customerNameTextField.text = familyName + givenName
        self.customerPhoneNumTextField.text = (contactProperty.value as! CNPhoneNumber).stringValue
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        
        if let personPhoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty) {
            
            let phone: ABMultiValueRef = personPhoneProperty.takeRetainedValue()
            let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue() as! String
            let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
            let index = ABMultiValueGetIndexForIdentifier(phone, identifier)
            var phoneNO = ABMultiValueCopyValueAtIndex(phone, index).takeRetainedValue() as! String
            if phoneNO.hasPrefix("+") {
                phoneNO = phoneNO.substringFromIndex(phoneNO.startIndex.advancedBy(3))
            }
            phoneNO = phoneNO.stringByReplacingOccurrencesOfString("-", withString: "")
            
            self.customerNameTextField.text = lastName + firstName
            self.customerPhoneNumTextField.text = phoneNO
            peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        } else {
            UITools.sharedInstance.toast("请选择电话号码")
        }
        
    }
    
    // MARK - Action
    
    @IBAction func addressBookBtnAction(sender: UIButton) {
        if #available(iOS 9, *) {
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            
            self.presentViewController(contactPicker, animated: true, completion: nil)
        } else {
            let peoplePicker = ABPeoplePickerNavigationController()
            peoplePicker.peoplePickerDelegate = self
            
            self.presentViewController(peoplePicker, animated: true, completion: nil)
        }
    }
    
    func checkboxViewClick(sender: UITapGestureRecognizer) {
        checkboxClick(checkBoxBtn)
    }
    
    func checkboxClick(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    func onClickLeftBarBtn(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var flag = true
    func onClickRightBarBtn(sender: UIBarButtonItem) {
        
        let name = customerNameTextField.text
        let phone = customerPhoneNumTextField.text
        if name == nil || name!.isEmpty {
            UITools.sharedInstance.toast("请输入乘车人姓名")
            
            UITools.sharedInstance.shakeView(customerNameTextField)
            return
        }
        if phone == nil || phone!.isEmpty {
            UITools.sharedInstance.toast("请输入乘车人电话号码")
            
            UITools.sharedInstance.shakeView(customerPhoneNumTextField)
            return
        }
        let data = CustomerInfo()
        data.name = name!
        data.phone = phone!
        data.sendSMS = checkBoxBtn.selected
        NSNotificationCenter.defaultCenter().postNotificationName(identifier, object: data)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo  = notification.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        keyboardHeight = keyBoardBounds.size.height
    }
    
    func handleTouches(sender:UITapGestureRecognizer){
        
        if sender.locationInView(self.view).y < self.view.bounds.height - keyboardHeight {
            customerNameTextField.resignFirstResponder()
            customerPhoneNumTextField.resignFirstResponder()
        }
    }

}

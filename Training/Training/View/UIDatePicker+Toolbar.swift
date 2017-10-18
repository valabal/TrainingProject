//
//  UIDatePicker+Toolbar.swift
//  EmveepApp
//
//  Created by Valbal on 12/7/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import Foundation
import UIKit

@objc protocol UIDatePickerDelegate{
    func dateChanged(sender: AnyObject)
    func datePickerDonePressed(sender: AnyObject)
    func datePickerCancelPressed(sender: AnyObject)
}

extension UIDatePicker {
 
    func setMaxDate(date : NSDate){
    
        self.datePickerMode = UIDatePickerMode.date
        self.locale = NSLocale.init(localeIdentifier: "en_US") as Locale
        self.date = NSDate() as Date
        self.maximumDate = NSDate() as Date
        
    }
   
    func setupForTextField(textField : UITextField, viewController :UIDatePickerDelegate){
       
        self.setupForTextField(textField: textField, viewController: viewController, doneStatus: "Next")
        
    }
    
    func setupForTextField(textField : UITextField, viewController :UIDatePickerDelegate, doneStatus : String){

        self.addTarget(viewController, action: #selector(UIDatePickerDelegate.dateChanged(sender:)), for: .valueChanged)
    
        let vc = viewController as! UIViewController
        
        let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width:vc.view.frame.width, height: 44))
        toolbar.barStyle = UIBarStyle.default
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem.init(title:doneStatus, style: UIBarButtonItemStyle.plain, target: viewController, action:  #selector(UIDatePickerDelegate.datePickerDonePressed(sender:)))

        toolbar.items = [flexibleSpace,doneButton]
        textField.inputView = self;
        textField.inputAccessoryView = toolbar;
        
    }
    
}

//
//  UIPickerView+MenuBar.swift
//  EmveepApp
//
//  Created by Valbal on 12/7/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let pickerTaped = Notification.Name("PickerDidTaped")
}


extension UIPickerView {
    
    func setupForTextField(textField : UITextField, viewController : UIViewController){
        self.setupForTextField(textField: textField, viewController: viewController, doneStatus: "Next")
    }
    
    func setupForTextField(textField : UITextField, viewController :UIViewController, doneStatus : String){
     
        let vc = viewController
        
        let toolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width:vc.view.frame.width, height: 44))
        toolbar.barStyle = UIBarStyle.default
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem.init(title:doneStatus, style: UIBarButtonItemStyle.plain, target: self, action:  #selector(triggerButtonTapped))
        
        toolbar.items = [flexibleSpace,doneButton]
        textField.inputView = self;
        textField.inputAccessoryView = toolbar;
    }
    
    func triggerButtonTapped(){

        NotificationCenter.default.post(name: (NSNotification.Name.pickerTaped), object: self)
        
        
    }
    
}



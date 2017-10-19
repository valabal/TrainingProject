//
//  FunctionHelper.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

let IDIOM  = UI_USER_INTERFACE_IDIOM()
let IPAD = UIUserInterfaceIdiom.pad

extension Notification.Name {
    static let ShowHUD = Notification.Name("ShowHUD")
    static let HideHUD = Notification.Name("HideHUD")
}


class FunctionHelper: NSObject {
    
    static func showHUD(){
       NotificationCenter.default.post(name: NSNotification.Name.ShowHUD, object: nil)
    }
    
    static func hideHUD(){
        NotificationCenter.default.post(name: NSNotification.Name.HideHUD, object: nil)
    }
    
    static func isHUDShown() -> Bool{
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate{
            
            if(delegate.HUD?.alpha == 0){
               return false
            }
            return true
        }
        return false
    
    }
    
    
    static func isIpad() -> Bool{
      
        if(IDIOM == IPAD){
            return true;
        }
        
        return false;
    }
    
    static func isTextFieldValid(textField : EmveepTextField) -> Bool{
      
        if textField.validationStatus == FloatLabeledTextFieldStatus.invalid{
          return false
        }

        return true;
        
    }
    
    static func unNullDictionary(dict : NSDictionary) -> NSDictionary{
      
        let keysToRemove = dict.allKeys.filter { dict[$0]! is NSNull}
      
        let result  = dict.mutableCopy() as! NSMutableDictionary
        
        for key in keysToRemove {
            result.removeObject(forKey: key)
        }
        
        return result
    
    }
    
}

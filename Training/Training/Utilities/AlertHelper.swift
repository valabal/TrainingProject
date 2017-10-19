//
//  AlertHelper.swift
//  EmveepApp
//
//  Created by Valbal on 1/13/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit

class AlertHelper: NSObject {
    
    
    static func showOfflineAlert(){
       
        EmveepAlertView.showAlert(withTitle: "Check your connection", message:"You need an internet connection to access this feature", cancelTitle: "OK", completion: {(cancelled:Bool, buttonIndex : NSInteger) in
        })
        
    }
    
    
    static func showAlert(title:String?,message:String?){

        let titles = title == nil ? "" : title
        let messages = message == nil ? "" : message
        
        EmveepAlertView.showAlert(withTitle: titles, message:messages, cancelTitle: "OK", completion: {(cancelled:Bool, buttonIndex : NSInteger) in
        })
        
    }
    
    
    static func changeCancelButtonColor(alertView:EmveepAlertView){
       
        alertView.setOtherButtonNonSelectedBackgroundColor(UIColor.init(colorLiteralRed: 126.0/255.0, green: 53.0/255.0, blue: 152.0/255.0, alpha: 55.0/255.0))
     
        alertView.setOtherButtonBackgroundColor(UIColor.init(colorLiteralRed: 126.0/255.0, green: 53.0/255.0, blue: 152.0/255.0, alpha: 155.0/255.0))
        
    }
    
    
}

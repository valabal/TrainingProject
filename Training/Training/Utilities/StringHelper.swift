//
//  StringHelper.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit

extension NSString{

    func StringIsValidEmail() -> Bool{
    
        let stricterFilter = false
        let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
        let emailRegex = stricterFilter ? stricterFilterString : laxString;
        let emailTest = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        
        return emailTest.evaluate(with: self)
        
    }
    
     func capitalizedFirstLetter()-> NSString{
       
        var capitalisedSentence : NSString = "";
    
        if (self.length > 0) {
            // Yes, it does.
            capitalisedSentence = self.replacingCharacters(in: NSMakeRange(0, 1), with: self.substring(to: 1).capitalized) as NSString
        }
        else {
            // No, it doesn't.
        }
        
        return capitalisedSentence
    
    }

}

extension NSNumber{
   
    func abbreviateNumber()->String{
        var abbrevNum = ""
        var floatNum = self.floatValue
        
        if self.intValue >= 1000{
          
            let abbrev = ["K","M","B"]
            
            for i in (0 ..< abbrev.count).reversed() {
                
                let size = NSDecimalNumber(decimal:pow(10,(i+1)*3)).floatValue
                
                if(size <= floatNum){
                   
                    floatNum = floatNum / size
                    let numberString = String(format: "%.1f", floatNum)
                    
                    abbrevNum = "\(numberString)\(abbrev[i])"
                }
            }
        }
        else{
           abbrevNum = String(format: "%.1f", floatNum)
        }
        
        return abbrevNum
        
    }
    

}


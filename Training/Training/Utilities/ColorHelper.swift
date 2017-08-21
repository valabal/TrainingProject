//
//  ColorHelper.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit
import Colours

extension UIColor{
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor{

    static var basicBackground : UIColor
        {return self.hexStringToUIColor(hex: "#FFFFFF")}

    static var navigationBarBackgroundColor : UIColor
        {return self.hexStringToUIColor(hex: "#CD1A5C")}
    
    static var navigationBackground : UIColor
        {return self.hexStringToUIColor(hex: "#CD1A5C")}
    
    static var navigationTextColor : UIColor
        {return self.hexStringToUIColor(hex: "#FFFFFF")}
    
    static var menuBackground : UIColor
        {return self.hexStringToUIColor(hex: "#A01111")}
    
    static var menuTextColor : UIColor
        {return self.hexStringToUIColor(hex: "#FFFFFF")}
    
    static var basicButtonColor : UIColor
        {return self.hexStringToUIColor(hex: "A01111")}
    
    static var submitButtonColor : UIColor
        {return self.hexStringToUIColor(hex: "#05AA20")}
    
    static var cancelButtonColor : UIColor
        {return self.hexStringToUIColor(hex: "#A10000")}
    
    static var yellowButtonColor : UIColor
        {return self.hexStringToUIColor(hex: "#FFF30F")}
    
    static var basicTextColor : UIColor
        {return self.hexStringToUIColor(hex: "#000000")}
    
    static var activeTextColor : UIColor
        {return self.hexStringToUIColor(hex: "#000000")}
    
    static var basicTextPlaceholderColor : UIColor
        {return self.hexStringToUIColor(hex: "#D8D8D8")}
    
    static var linkTextColor : UIColor
        {return self.hexStringToUIColor(hex: "#A01111")}
    
    static var alertTextColor : UIColor
        {return self.hexStringToUIColor(hex: "#A01111")}
    
    static var basicLineColor : UIColor
        {return self.hexStringToUIColor(hex: "#000000")}
    
    static var alertLineColor : UIColor
        {return self.hexStringToUIColor(hex: "#A01111")}

}




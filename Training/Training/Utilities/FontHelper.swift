//
//  FontHelper.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit

let TITLE_SIZE : CGFloat  = 18
let SUBTITLE_SIZE : CGFloat = 14
let SUBTITLE_MINI_SIZE : CGFloat = 11

extension UIFont {

    static func boldFontWithSize(size : CGFloat) -> UIFont{
      return UIFont.init(name: "ProximaNova-Bold", size: size)!
    }
    
    static func semiBoldFontWithSize(size : CGFloat) -> UIFont{
        return UIFont.init(name: "ProximaNova-Semibold", size: size)!
    }
    
    static func regularFontWithSize(size : CGFloat) -> UIFont{
        return UIFont.init(name: "ProximaNova-Regular", size: size)!
    }
    
    static func lightFontWithSize(size : CGFloat) -> UIFont{
        return UIFont.init(name: "ProximaNova-Light", size: size)!
    }
    
    static func getFontSizeFromLabel(label : UILabel) -> CGFloat{
      let fontSize = label.font.pointSize
      return fontSize

    }
    
}

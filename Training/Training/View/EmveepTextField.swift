//
//  EmveepTextField.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class EmveepTextField: MaterialDesignTextField {

    @IBInspectable
    var isBold: Bool = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame:CGRect) {
        
        super.init(frame:frame)
        self.commonInit()
    }
    
    override func commonInit(){
   
        super.commonInit()
        
        self.underlineNormalColor = UIColor.basicLineColor
        self.underlineHighlightedColor = UIColor.basicLineColor.lighten(0.25)
        self.errorColor = UIColor.alertTextColor
        self.floatingLabelTextColor = UIColor.basicTextColor.lighten(0.25);
        self.floatingLabelActiveTextColor = UIColor.activeTextColor;
        self.placeholderColor = UIColor.basicTextPlaceholderColor;
        self.textColor = UIColor.basicTextColor;
        
        if (self.isBold){
            self.font = UIFont.boldFontWithSize(size: (self.font?.pointSize)!)
        }
        else{
            self.font = UIFont.regularFontWithSize(size: (self.font?.pointSize)!)
        }

    }
 
}

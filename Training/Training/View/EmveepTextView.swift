//
//  EmveepTextView.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class EmveepTextView: JVFloatLabeledTextView {

    @IBInspectable
    var isBold: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame:CGRect, textContainer: NSTextContainer?) {
        super.init(frame:frame,textContainer:textContainer)
        self.commonInit()
    }
    
    override func commonInit(){
        
        super.commonInit()
        
        self.floatingLabelTextColor = UIColor.basicTextColor.lighten(0.25);
        self.floatingLabelActiveTextColor = UIColor.activeTextColor;
        self.textColor = UIColor.basicTextColor;
        self.font = UIFont.regularFontWithSize(size: (self.font?.pointSize)!);
        
        if (self.isBold){
            self.font = UIFont.boldFontWithSize(size: (self.font?.pointSize)!)
        }
        else{
            self.font = UIFont.regularFontWithSize(size: (self.font?.pointSize)!)
        }
        
    }
    
}

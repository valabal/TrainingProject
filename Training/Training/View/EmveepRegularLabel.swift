//
//  EmveepRegularLabel.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit

public extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get { return layer.borderColor.map(UIColor.init) }
        set { layer.borderColor = newValue?.cgColor }
    }
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
}

extension UILabel{

    func setOptionalText(text:String?){
        if let title = text {
            self.text = title
        }
        else{
          self.text = ""
        }
    }

}



class EmveepRegularLabel: UILabel {

    @IBInspectable
    var isBold: Bool = false{
       
        didSet {
            self.commonInit()
        }
        
    }
    
    @IBInspectable
    var untranslated: Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        setNeedsDisplay()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.commonInit()
        setNeedsDisplay()
    }
    
    func commonInit(){
       
        if (self.isBold){
          self.font = UIFont.boldFontWithSize(size: self.font.pointSize)
        }
        else{
          self.font = UIFont.regularFontWithSize(size: self.font.pointSize)
        }
    
    }
    
    override public var text: String? {
        didSet {
            if(self.untranslated){
              super.text = text
            }
            else{
               //get Translated Text
                super.text = text
            }
        }
    }
    
}

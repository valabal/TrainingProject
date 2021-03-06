//
//  EmveepRegularButton.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit

public typealias ActionBlock = () -> Swift.Void

class ActionButton:UIButton{
    
    var actionBlock : ActionBlock?
    
    func handleControlEvent(event:UIControlEvents,block: @escaping ActionBlock){
        
        self.actionBlock = block
        self.addTarget(self, action: #selector(callActionBlock(sender:)), for: event)
        
    }
    
    func callActionBlock(sender:Any){
        self.actionBlock?()
    }
    
}

class EmveepRegularButton: ActionButton {
    
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
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }


    func commonInit(){
        
        if (self.isBold){
            self.titleLabel?.font = UIFont.boldFontWithSize(size: (self.titleLabel?.font.pointSize)!)
        }
        else{
            self.titleLabel?.font = UIFont.regularFontWithSize(size: (self.titleLabel?.font.pointSize)!)
        }
        
    }
    
    
}

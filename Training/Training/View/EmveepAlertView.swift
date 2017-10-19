//
//  EmveepAlertView.swift
//  EmveepApp
//
//  Created by Valbal on 1/13/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import PXAlertView

class EmveepAlertView: PXAlertView {

    var cancelButton:UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.useDefaultStyle()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.useDefaultStyle()
    }
    
    override init!(title: String!, message: String!, cancelTitle: String!, otherTitles: [Any]!, buttonsShouldStack shouldstack: Bool, contentView: UIView!, completion: PXAlertViewCompletionBlock!) {
        super.init(title: title, message: message, cancelTitle: cancelTitle, otherTitles: otherTitles, buttonsShouldStack: shouldstack, contentView: contentView, completion: completion)
        self.useDefaultStyle()
    }
    
    override init!(title: String!, message: String!, cancelTitle: String!, otherTitle: String!, buttonsShouldStack shouldstack: Bool, contentView: UIView!, completion: PXAlertViewCompletionBlock!) {
        super.init(title: title, message: message, cancelTitle: cancelTitle, otherTitle: otherTitle, buttonsShouldStack: shouldstack, contentView: contentView, completion: completion)
        self.useDefaultStyle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func useDefaultStyle(){
        self.setAllButtonsTextColor(UIColor.white)
        self.setTitleColor(UIColor.alertTextColor)
        self.setMessageColor(UIColor.black)
        
        let normalColor = UIColor.basicButtonColor
        let tapColor = normalColor.darken(0.25)
        let cancelColor = UIColor.cancelButtonColor
        
        self.setAllButtonsBackgroundColor(tapColor)
        self.setAllButtonsNonSelectedBackgroundColor(normalColor)
        self.setCancelButtonTextColor(cancelColor)

        let defaultBackgroundColor = UIColor.basicBackground
        self.setBackgroundColor(defaultBackgroundColor)
        
        self.setTitleFont(UIFont.regularFontWithSize(size: TITLE_SIZE))
        self.setMessageFont(UIFont.regularFontWithSize(size: SUBTITLE_SIZE))
        self.setAllButtonsFont(UIFont.regularFontWithSize(size: SUBTITLE_SIZE))
        
        let lineView = self.view.viewWithTag(12345)
        
        if let view : UIView = lineView{
           view.backgroundColor = UIColor.alertLineColor
        }
        
    }
    
    func addTopCancelButton(){
       
        var titleFrame = self.titleLabel.frame;
        titleFrame.origin.x = titleFrame.size.width - titleFrame.size.height + 10
        titleFrame.size.width = titleFrame.size.height
        let closeBut = UIButton.init(frame: titleFrame)
        closeBut.titleLabel?.font = self.titleLabel.font
        closeBut.setTitleColor(self.titleLabel.textColor, for: UIControlState.normal)
        closeBut.addTarget(self, action: #selector(dismiss(_:)), for: UIControlEvents.touchUpInside)
        closeBut.tag = 4567
        self.alertView.addSubview(closeBut)
    
    }
    
    func getCancelButton() -> UIButton?{
       return self.cancelButton
    }
    
    func removeCancelActionObserver(){
      
        self.cancelButton?.removeTarget(self, action: #selector(dismiss(_:)), for:UIControlEvents.touchUpInside)
        
    }
    

}

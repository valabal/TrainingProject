//
//  BasicViewController.swift
//  EmveepApp
//
//  Created by Valbal on 1/13/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import SnapKit

class BasicViewController: UIViewController {

    var isFirstTimeLoad : Bool?
    @IBOutlet var tableView : UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.settingNavMenuBarWithTitle(title:nil)
        self.settingRightNavButtonWithView(arrayOfUIView:nil)
        
        self.tableView?.register(UINib(nibName: "BasicViewCell", bundle: nil), forCellReuseIdentifier: "basicCell")
        self.tableView?.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func settingNavBar(){
       
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBackground
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationBackground
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont.regularFontWithSize(size: TITLE_SIZE)]
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        
    }

    func settingNavMenuBarWithTitle(title : NSString?){
      
        self.settingNavBar()
        self.settingBarWithTitle(title: title)
        let leftView = BasicViewController.generateMenuButtonViewWithImage(image: UIImage(named: "more_icon"), action: #selector(showMenu), target: self)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15

        self.navigationItem.setLeftBarButtonItems([negativeSpacer,UIBarButtonItem(customView: leftView!)], animated: false)
        
    }
    
    func settingNavBackBarWithTitle(title:NSString?){
        self.settingNavBar()
        self.settingBarWithTitle(title: title)
        
        let leftView = BasicViewController.generateMenuButtonViewWithImage(image: UIImage(named: "back"), action: #selector(goBack), target: self)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        self.navigationItem.setLeftBarButtonItems([negativeSpacer,UIBarButtonItem(customView: leftView!)], animated: false)
        
    }
    
    func settingBarWithTitle(title : NSString?){
        
        if title != nil{
           self.navigationItem.title = title as String?
        }
        else{
            self.navigationItem.title = "Home"
        }
        
    }
    
    
    func settingRightNavButtonWithView(arrayOfUIView : [UIView]?){
       
        if(arrayOfUIView == nil){
            self.navigationItem .setRightBarButtonItems(nil,animated:false)
            return;
        }
        
        var width : CGFloat = 0.0
        var originX : CGFloat = 0.0
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 40))
    
        
        for view in arrayOfUIView!{
         
            if(!view.frame.equalTo(CGRect.zero)){
              
                view.frame = CGRect(x: Double(originX), y: 0.0, width: Double(view.frame.size.width), height: 40.0)
                rightView.addSubview(view)
                
                width = CGFloat(view.frame.size.width) + CGFloat(view.frame.origin.x)
                originX = width
                
            }
            
        }
        
        rightView.frame = CGRect(x: 0, y: 0, width: width, height: 40)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.setRightBarButtonItems([negativeSpacer,UIBarButtonItem(customView: rightView)], animated: false)
        
    }
    
    
    func settingLeftNavButtonWithView(arrayOfUIView : [UIView]?){
      
        
        if(arrayOfUIView == nil){
            self.navigationItem .setLeftBarButtonItems(nil,animated:false)
            return;
        }
        
        var width : CGFloat = 0.0
        var originX : CGFloat = 0.0
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 40))
        
        
        for view in arrayOfUIView!{
            
            if(!view.frame.equalTo(CGRect.zero)){
                
                view.frame = CGRect(x: Double(originX), y: 0.0, width: Double(view.frame.size.width), height: 40.0)
                rightView.addSubview(view)
                
                width = CGFloat(view.frame.size.width) + CGFloat(view.frame.origin.x)
                originX = width
                
            }
            
        }
        
        rightView.frame = CGRect(x: 0, y: 0, width: width, height: 40)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -5
        
        self.navigationItem.setLeftBarButtonItems([negativeSpacer,UIBarButtonItem(customView: rightView)], animated: false)
        
    }
    
    func showMenu(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowMenuBar"), object: nil)
    }
    
    func goBack(){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    static func generateMenuButtonViewWithImage(image : UIImage?, action: Selector, target : Any?) -> UIView?{
      
        let leftView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        let imageView : UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        leftView.addSubview(imageView)
        
        let button : UIButton = UIButton(type: UIButtonType.custom)
        button.frame =  CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        leftView.addSubview(button)
    
        return leftView
        
    }
    
    static func generateMenuButtonViewWithTitle(title : String?, action: Selector, target : Any?) -> UIView?{
        
        
        let leftView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 40)
        )
        
        let button : UIButton = UIButton(type: UIButtonType.custom)
        button.titleLabel?.font = UIFont.regularFontWithSize(size: 16.0)
        button.setTitle(title, for: UIControlState.normal)
        button.frame =  CGRect(x: 0, y: 0, width: 55, height: 41)
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        leftView.addSubview(button)
        
        return leftView
        
    }
    
    static func generateMenuButtonViewWithImageLitter(image : UIImage?, action: Selector, target : Any?) -> UIView?{
        
        let leftView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        let imageView : UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 8, y: 8, width: 24, height: 24)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        leftView.addSubview(imageView)
        
        let button : UIButton = UIButton(type: UIButtonType.custom)
        button.frame =  CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        leftView.addSubview(button)
        
        return leftView
        
    }
    
    
    func createViewFromButtonArray(_ array : [UIView])->UIView{
       
        let container = UIView()
        var prevButton : UIView? = nil
        var counter = 0
        
        for button:UIView in array {
          container.addSubview(button)
            
          var isButtonImage = true
            
            if let but = button as? UIButton{
                isButtonImage = but.image(for: .normal) != nil ? true : false
                let edge = but.contentEdgeInsets
                if(UIEdgeInsetsEqualToEdgeInsets(edge, UIEdgeInsetsMake(0, 0, 0, 0))){
                  but.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
                }
            }
            
            button.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(container)
                make.bottom.equalTo(container)

                if(isButtonImage){
                    make.width.equalTo(40)
                }
                
                make.height.equalTo(40)
                
                if(prevButton == nil){
                  make.leading.equalTo(container)
                }
                else{
                  make.leading.equalTo(prevButton!.snp.trailing)
                }
                
                if(counter == array.count-1){
                  make.trailing.equalTo(container)
                }
            })

            prevButton = button
            counter += 1
            
        }
     
        return container
    
    }
    
    
}

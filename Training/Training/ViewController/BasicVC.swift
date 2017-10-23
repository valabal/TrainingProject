//
//  BasicViewController.swift
//  EmveepApp
//
//  Created by Valbal on 1/13/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol BindingViews {
    func bindingViews()
}

class BasicVC: UIViewController,BindingViews {

    var isFirstTimeLoad : Bool?
    @IBOutlet var tableView : UITableView?

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingNavigationMenu()
        
        self.tableView?.register(UINib(nibName: "BasicViewCell", bundle: nil), forCellReuseIdentifier: "basicCell")
        self.tableView?.separatorStyle = .none
        self.tableView?.estimatedRowHeight = 100.0

        self.bindingViews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        print(String(describing:type(of: self))+" DEINIT")
    }
    
    
    func settingNavigationMenu(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.settingNavBarWithTitle()
        self.settingRightNavButtonWithView(arrayOfUIView:nil)
    }
    
    func bindingViews(){
    
    }
    
}

struct CellModel {
    
    var identifier : String
    var content : AnyObject?
    
    init(_ identifier:String,content:AnyObject? = nil){
        self.identifier = identifier
        self.content = content
    }
    
}



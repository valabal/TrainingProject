//
//  MainVC.swift
//  Training
//
//  Created by Valbal on 8/21/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit

class MainVC: BasicViewController{

    var content : NSMutableArray = NSMutableArray()
    var currentPage : Int = 0
    var isInSession : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingBarWithTitle(title:"Merchant List")
    
        self.settingRightNavButtonWithView(arrayOfUIView: [BasicViewController.generateMenuButtonViewWithImage(image: UIImage.init(named: "shutdown"), action:#selector(logOff), target: self)!])

        self.getRestaurantList()

        //add Pull To Refresh
        self.tableView?.addPullToRefreshWithActionHandler { () -> Void in
            self.tableResetPaginationBlock()
        }
        
        self.tableView?.addInfiniteScrollingWithActionHandler {
            self.tablePaginationBlock()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logOff(){
        UserManager.saveAccessToken(token: nil)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.resetAllViews(modalVC: nil)
    }
    
    func tableResetPaginationBlock() {
        getRestaurantList(false,needReset : true)
    }
    
    func tablePaginationBlock() {
        getRestaurantList(false,needReset : false)
    }
    
    func getRestaurantList(){
      self.getRestaurantList(true,needReset : true)
    }
    
    func getRestaurantList(_ isShowHUD:Bool, needReset:Bool){
   
        if(isInSession){return}
        
        if(isShowHUD){
          FunctionHelper.showHUD()
        }
        
        let request = ListMerchantRequest()
        request.search_type = "all";
        request.order_alphabetically = true
        
        if(needReset){
           currentPage = 0
        }
        
        request.page = NSNumber(value: currentPage)
        isInSession = true
        
        APIManager.MerchantList(request: request , callback: {(result : NSDictionary?) in
            if(isShowHUD){
              FunctionHelper.hideHUD()
            }
            guard let merchants = result?["results"] as? [NSDictionary] else {
               return
            }
            
            if(needReset){
              self.content = NSMutableArray()
            }
            
            for dic in merchants{
               let merchant = Merchant(dictionary: dic)
               self.content.add(merchant)
            }
          
            self.currentPage += 1;
            
            if(needReset){
                self.tableView?.setContentOffset(CGPoint.zero, animated: true)
            }
            
            self.tableView?.reloadData()
            self.tableView?.stopPullToRefresh()
            
            if let pagination = result?["pagination"] as? NSDictionary, let nextPages = pagination["next_page"]{
                self.tableView?.showsInfiniteScrolling = true
                self.tableView?.infiniteScrollingView.stopAnimating()
            }
            else{
                self.tableView?.showsInfiniteScrolling = false
            }
            
            self.isInSession = false
            
         }
            , failure: {(error : Error?) in

            if(isShowHUD){
                FunctionHelper.hideHUD()
            }
            
            self.tableView?.stopPullToRefresh()
            self.tableView?.showsInfiniteScrolling = false
                
            self.isInSession = false
        
        })
        
    }
    
    
}


extension MainVC:UITableViewDelegate,UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BasicViewCell  = tableView.dequeueReusableCell(withIdentifier: "basicCell")! as! BasicViewCell
        
        if let merchant = self.content[indexPath.row] as? Merchant{
            let object = merchant.convertToCellObject()
            cell.fillCellWithObject(object: object)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if let merchant = self.content[indexPath.row] as? Merchant{

            if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailVC{
                detailVC.current_merchant = merchant
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
         
        }
        
    }
    
    
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingBarWithTitle(title:"Merchant List")
    
        self.settingRightNavButtonWithView(arrayOfUIView: [BasicViewController.generateMenuButtonViewWithImage(image: UIImage.init(named: "shutdown"), action:#selector(logOff), target: self)!])
    
        self.tableView?.estimatedRowHeight = 100.0
        
        self.getRestaurantList()
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
    
    func getRestaurantList(){
    
        FunctionHelper.showHUD()
        
        let request = ListMerchantRequest()
        request.search_type = "all";
        request.order_alphabetically = true
        
        APIManager.MerchantList(request: request , callback: {(result : NSDictionary?) in
            FunctionHelper.hideHUD()
        
            guard let merchants = result?["results"] as? [NSDictionary] else {
               return
            }
            
            self.content = NSMutableArray()
            
            for dic in merchants{
               let merchant = Merchant(dictionary: dic)
               self.content.add(merchant)
            }
          
            self.tableView?.reloadData()
            
         }
            , failure: {(error : Error?) in
            FunctionHelper.hideHUD()
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

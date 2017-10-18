//
//  DetailModal.swift
//  Training
//
//  Created by Valbal on 8/30/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import SnapKit

class DetailModal: BasicViewController{
    
    var merchant : Merchant!
    
    override func viewDidLoad() {
       super.viewDidLoad()
    }
    
    @IBAction func closeDidTapped(){
       self.goBack()
    }

}


extension DetailModal:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let additionalDetail = self.merchant.merchant_detail?.additional_features?.count ?? 0
        
        return 2+additionalDetail
    
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BasicViewCell  = tableView.dequeueReusableCell(withIdentifier: "basicCell")! as! BasicViewCell
      
        if(indexPath.row == 0){
            
            let basicObj = BasicCellObject()
            basicObj.title = self.merchant.name?.uppercased()
            basicObj.subTitle = self.merchant.type?.uppercased()
            
            if let openHour = self.merchant.merchant_detail?.open_hour, let closedHour = self.merchant.merchant_detail?.close_hour {
                
                let startHourDate = Date.dateFromString(dateString: openHour, dateFormat: "HH:mm")
                let endHourDate = Date.dateFromString(dateString: closedHour, dateFormat: "HH:mm")
                
                let hour = "OPEN : \(Date.stringFromDate(dateInput: startHourDate, dateFormat: "hh:mm a")) - \(Date.stringFromDate(dateInput: endHourDate, dateFormat: "hh:mm a"))"
                
                basicObj.descString = hour
            
            }
            
            basicObj.imageURL = self.merchant.logo_url
            cell.fillCellWithObject(object: basicObj)
            
        }
        else if(indexPath.row == 1){
         
            let basicObj = BasicCellObject()
            basicObj.title = "Description"
            basicObj.descString = self.merchant.merchant_detail?.descriptions
            basicObj.subTitle = self.merchant.price_rating
            cell.fillCellWithObject(object: basicObj)
            
        }
        else{
            
            let additionalDetail = self.merchant.merchant_detail?.additional_features!
            let featDic = additionalDetail![indexPath.row-2]
            
            let basicObj = BasicCellObject()
            basicObj.title = featDic["name"] as? String
        
            cell.fillCellWithObject(object: basicObj)
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
}

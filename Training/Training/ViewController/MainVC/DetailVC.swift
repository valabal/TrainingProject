//
//  DetailVC.swift
//  Training
//
//  Created by Valbal on 8/28/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import SnapKit

class DetailVC: BasicViewController{
    
    @IBOutlet var iconView : UIImageView?
    @IBOutlet var restaurantTypeLbl : UILabel?
    @IBOutlet var restaurantNameLbl : UILabel?
    @IBOutlet var pageControl : UIPageControl?
    
    var imageScrollView : UIScrollView?
    var timer : Timer? = nil
    
    var current_merchant : Merchant?
    var state : ProductType = .NORMAL
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingNavBackBarWithTitle(title: "Merchant Detail")
        
        
        if let infoBut = BasicViewController.generateMenuButtonViewWithImage(image: UIImage(named:"info_whte"), action:#selector(goToModalDetail), target: self)
        {self.settingRightNavButtonWithView(arrayOfUIView: [infoBut])}
        
        self.refreshView()
        
        self.getRestaurantDetail()
        
        self.tableView?.estimatedRowHeight = 100.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (timer == nil){
            timer = Timer.scheduledTimer(withTimeInterval: 7.5, repeats: true, block:{(timer : Timer) in
                self.slideShow()
            })
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let timer = timer{
            timer.invalidate()
            self.timer = nil
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func goToModalDetail(){
    
        if let detailModal = self.storyboard?.instantiateViewController(withIdentifier: "DetailModal") as? DetailModal{
            detailModal.merchant = self.current_merchant
            detailModal.providesPresentationContextTransitionStyle = true
            detailModal.definesPresentationContext = true
            detailModal.modalPresentationStyle = .overCurrentContext
            detailModal.modalTransitionStyle = .crossDissolve
            self.navigationController?.present(detailModal, animated: true, completion: nil)
        }
        
    }
    
    
    func refreshView(){
        if let url = self.current_merchant?.logo_url{
            self.iconView?.sd_setImage(with: URL(string: url))
        }
        
        self.restaurantNameLbl?.text = self.current_merchant?.name
        self.restaurantTypeLbl?.text = self.current_merchant?.type
        
        self.tableView?.reloadData()
    }
    
    
    func getRestaurantDetail(){
        
        guard let merchant_id = self.current_merchant?.merchant_id else{
            return
        }
        
        FunctionHelper.showHUD()
        
        APIManager.MerchantDetail(merchantID:merchant_id , callback: {(result : NSDictionary?) in
            
            FunctionHelper.hideHUD()
            
            guard let merchants = result?["merchant"] as? NSDictionary else {
                return
            }
            
            self.current_merchant = Merchant(dictionary: merchants)
            self.current_merchant?.products = result?["products"] as? NSDictionary
            
            self.createHeaderView()
            self.tableView?.reloadData()
            
        }
            , failure: {(error : Error?) in
                FunctionHelper.hideHUD()
        })
        
    }
    
    
    func openLink(_ link:String){
        
        if let url = URL(string: link){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    
}

extension DetailVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.current_merchant?.merchant_detail) != nil {
            return self.getRowNumber()
        }
        
        return 0
    }
    
    
    func getRowNumber() -> Int{
        
        var numberOfCell = 2
        
        if (self.current_merchant?.products) != nil {
            
            var counter = 1
            
            if let products = self.current_merchant?.getProductType(state: self.state){
                counter = products.count == 0 ? 1 : products.count
            }
            
            numberOfCell = numberOfCell+1+counter
        }
        
        return numberOfCell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.row == 0){
            return 45
        }
        else if(indexPath.row == 1){
            return 60
        }
        else if (indexPath.row == 2){
            return 40;
        }
        
        if (self.current_merchant?.products) != nil{
            
            if let products = self.current_merchant?.getProductType(state: state), products.count == 0{
                //empty cell
                var sisaTinggi = tableView.frame.size.height - (45 + 60 + 40)
                sisaTinggi = sisaTinggi - tableView.frame.size.width*6/14 //headerView
                sisaTinggi = sisaTinggi > 165 ? sisaTinggi : 165
                return sisaTinggi
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if(indexPath.row == 1){
            cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
            let addressLbl = cell.viewWithTag(1) as? UILabel
            let cityLbl = cell.viewWithTag(2) as? UILabel
            
            addressLbl?.text = self.current_merchant?.place?.address
            cityLbl?.text = "\(self.current_merchant?.location_id)"
        }
        else if (indexPath.row == 0){
            cell = tableView.dequeueReusableCell(withIdentifier: "buttonsCell")!
            
            var view = cell.viewWithTag(1)
            if (view == nil){
                view = self.createSocialButtonView(cell: cell)
            }
            
        }
        else if (indexPath.row == 2){
            cell = tableView.dequeueReusableCell(withIdentifier: "segmentCell")!
            
            if let offerBut = cell.viewWithTag(1) as? EmveepRegularButton,let monthBut = cell.viewWithTag(2) as? EmveepRegularButton{
             
                offerBut.handleControlEvent(event: .touchUpInside, block: {() in
                    self.state = .NORMAL
                    self.tableView?.reloadData()
                })
                
                monthBut.handleControlEvent(event: .touchUpInside, block: {() in
                    self.state = .MONTHLY
                    self.tableView?.reloadData()
                })
                
                if (self.state == .NORMAL){
                     offerBut.setTitleColor(UIColor.black, for: .normal)
                     monthBut.setTitleColor(UIColor.blue, for: .normal)
                }
                else{
                    offerBut.setTitleColor(UIColor.blue, for: .normal)
                    monthBut.setTitleColor(UIColor.black, for: .normal)
                }
            }
            
        }
        else{
            
            guard let product = self.current_merchant?.getProductType(state: self.state), product.count > 0 else{
                cell = tableView.dequeueReusableCell(withIdentifier: "redeemEmptyCell")!
                return cell
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            
            let offerDic = product[indexPath.row-3]
            let offer = Offer(dictionary: offerDic)
            let object = offer.convertToCellObject()
            
            if let cell = cell as? BasicViewCell{
                cell.fillCellWithObject(object: object)
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}

//MARK: Create Custom View
extension DetailVC{
    
    func createSocialButtonView(cell:UITableViewCell)->UIView{
        
        let view = UIView()
        view.tag = 1
        cell.addSubview(view)
        
        view.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(40).priority(10)
            make.centerY.equalTo(cell);
            make.left.equalTo(cell);
            make.right.equalTo(cell);
        })
        
        var socialButtons : [[String:Any]] = []
        
        if let url = self.current_merchant?.merchant_detail?.additional_details?["instagram"]{
            let dic = ["type":"instagram","image":"instagram","link":url]
            socialButtons.append(dic)
        }
        
        if let url = self.current_merchant?.merchant_detail?.additional_details?["facebook"]{
            let dic = ["type":"facebook","image":"facebook","link":url]
            socialButtons.append(dic)
        }
        
        if let url = self.current_merchant?.merchant_detail?.additional_details?["web"]{
            let dic = ["type":"web","image":"web","link":url]
            socialButtons.append(dic)
        }
        
        var buttonArray : [UIButton] = []
        let buttonInset = UIEdgeInsetsMake(8,8,8,8)
        
        for dic:[String:Any] in socialButtons{
            let button = EmveepRegularButton()
            button.setImage(UIImage(named: dic["image"] as! String), for:.normal)
            button.contentEdgeInsets = buttonInset
            
            button.handleControlEvent(event: .touchUpInside, block: {() in
                
                if let urlString = dic["link"] as? String
                {self.openLink(urlString)}
                
            })
            
            buttonArray.append(button)
        }
        
        let socialButtonContainer = self.createViewFromButtonArray(buttonArray)
        
        var rightButtons : [UIButton] = []
        
        if let phones = self.current_merchant?.merchant_detail?.additional_details?["phone"]{
            let phoneButton = EmveepRegularButton()
            phoneButton.setImage(UIImage(named: "phone"), for: .normal)
            phoneButton.contentEdgeInsets = buttonInset
            
            phoneButton.handleControlEvent(event: .touchUpInside, block: {() in
                let phoneNumber = "tel://\(phones)"
                if let url = URL(string: phoneNumber){
                    if(UIApplication.shared.canOpenURL(url)){
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    else{
                        AlertHelper.showAlert(title: "Error", message: "Cannot Called : \(phones)")
                    }
                }
            })
            
            rightButtons.append(phoneButton)
            
        }
        
        let locButton = EmveepRegularButton()
        locButton.setImage(UIImage(named: "pin"), for: .normal)
        locButton.contentEdgeInsets = buttonInset
        locButton.handleControlEvent(event: .touchUpInside, block: {() in
            
            if let lat = self.current_merchant?.place?.coordinate?["lat"], let long = self.current_merchant?.place?.coordinate?["lng"]{
                let urlString = "https://maps.google.com/?daddr=\(lat),\(long)&directionsmode=driving"
                self.openLink(urlString)
            }
            
        })
        
        rightButtons.append(locButton)
        
        if let menus = self.current_merchant?.merchant_detail?.additional_details?["menu"]{
            let menuButton = EmveepRegularButton()
            menuButton.setImage(UIImage(named: "menu"), for: .normal)
            menuButton.contentEdgeInsets = buttonInset
            
            menuButton.handleControlEvent(event: .touchUpInside, block: {() in
                
                if let urlString = menus as? String
                {self.openLink(urlString)}
                
            })
            
            
            rightButtons.append(menuButton)
        }
        
        let rightButtonContainer = self.createViewFromButtonArray(rightButtons)
        
        rightButtonContainer.setContentCompressionResistancePriority(800, for: .horizontal)
        view.addSubview(socialButtonContainer)
        socialButtonContainer.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(view)
            make.top.equalTo(view)
            make.left.equalTo(view)
        })
        
        view.addSubview(rightButtonContainer)
        
        rightButtonContainer.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
        })
        
        return view;
        
    }
    
    
    func createHeaderView(){
        
        if (self.tableView?.tableHeaderView) != nil{
            return
        }
        
        guard let tableView = self.tableView else{
            return
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.width*6/14))
        
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints({ (make) -> Void in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        
        let images = self.current_merchant?.merchant_detail?.images
        var prevContent : UIView? = nil
        
        var count = 0
        
        if let imageNumber = images?.count{
            count = imageNumber
        }
        
        for i in 0 ..< count {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
            
            imageView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(scrollView)
                make.width.equalTo(view)
                make.height.equalTo(view)
                
                if(i == 0){
                    make.left.equalTo(scrollView)
                }
                
                if(prevContent != nil && i<count-1){
                    make.left.equalTo(prevContent!.snp.right)
                }
                else if(i == count-1){
                    
                    if(prevContent != nil){
                        make.left.equalTo(prevContent!.snp.right)
                    }
                    
                    make.right.equalTo(scrollView)
                }
            })
            
            imageView.sd_setImage(with: URL(string:images![i]))
            prevContent = imageView
        }
        
        imageScrollView = scrollView
        
        if(count>1){
            
            pageControl = UIPageControl()
            pageControl?.numberOfPages = count
            pageControl?.isEnabled = false
            pageControl?.currentPage = 0
            view.addSubview(pageControl!)
            
            pageControl?.snp.makeConstraints({ (make) -> Void in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-5)
            })
            
        }
        
        let headerView = ParallaxHeaderView.parallaxHeaderView(withSubView: view)
        self.tableView?.tableHeaderView = headerView as! UIView?
        
    }
    
    func setPageControlCurrentPage(){
        
        guard let imageScrollView = imageScrollView, let pageControl = pageControl else{
            return
        }
        
        let horizontalOffset = imageScrollView.contentOffset.x
        let screenWidth = self.view.frame.size.width
        
        let page = horizontalOffset/screenWidth
        pageControl.currentPage = Int(page)
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let tableView = self.tableView, scrollView == tableView{
            if let paralax = self.tableView?.tableHeaderView as? ParallaxHeaderView{
                paralax.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
            }
        }
        else if let imageScrollView = imageScrollView, scrollView == imageScrollView{
            self.setPageControlCurrentPage()
        }
    }
    
    func slideShow(){
        
        if let images = self.current_merchant?.merchant_detail?.images, images.count > 1,let pageControl = pageControl{
            
            var currentPage = pageControl.currentPage
            currentPage = currentPage+1
            
            if(currentPage > images.count-1){
                currentPage  = 0
            }
            
            if let scrollViews = imageScrollView {
                scrollViews.setContentOffset(CGPoint(x: CGFloat(currentPage)*scrollViews.frame.size.width, y: 0), animated: true)
            }
            
            self.setPageControlCurrentPage()
            
        }
        
    }
    
}





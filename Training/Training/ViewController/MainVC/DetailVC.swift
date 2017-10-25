//
//  DetailVC.swift
//  Training
//
//  Created by Valbal on 8/28/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DetailVC: BasicVC{
    
    @IBOutlet var iconView : UIImageView?
    @IBOutlet var restaurantTypeLbl : UILabel?
    @IBOutlet var restaurantNameLbl : UILabel?
    @IBOutlet var pageControl : UIPageControl?
    
    var scrViewDisposeBag = DisposeBag()
    
    var imageScrollView : UIScrollView?{

        didSet{
            scrViewDisposeBag = DisposeBag()
             self.imageScrollView?.rx.didScroll.subscribe(onNext:{[unowned self] _ in
                self.setPageControlCurrentPage()
                }
            ).disposed(by: scrViewDisposeBag)
        }
   
    }
    
    var merchant : Merchant = Merchant(){
        didSet{
            
            if let url = merchant.logo_url{
                self.iconView?.sd_setImage(with: URL(string: url))
            }
            
            self.restaurantNameLbl?.text = merchant.name
            self.restaurantTypeLbl?.text = merchant.type
            
            self.refreshTableContent()
            
        }
    }
    
    var state : ProductType = .NORMAL{
        didSet{
            self.refreshTableContent()
        }
    }
    
    var tableContent : [CellModel] = []{
        didSet{
            self.tableView?.reloadData()
        }
    }
    
    var viewModel : DetailVM!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.estimatedRowHeight = 100.0
    }
    
    override func settingNavigationMenu() {
        self.settingNavBackBarWithTitle("Merchant Detail")
        let infoBut = UIViewController.generateMenuButtonViewWithImage(image: UIImage(named:"info_whte"), action:#selector(goToModalDetail), target: self)
        self.settingRightNavButtonWithView(arrayOfUIView: [infoBut])
    }
    
    override func bindingViews(){
        
        let refreshMerchant:PublishSubject<Void> = PublishSubject<Void>()
        
        //input
        refreshMerchant.bind(to: self.viewModel.inputs.loadMerchantDetail).disposed(by: disposeBag)
        
        //output
        let response = self.viewModel.outputs.current_merchant.asDriver().asObservable()
        
        response.subscribe(onNext:{
            [unowned self] merchant in
            self.merchant = merchant
        }).disposed(by: disposeBag)
        
        response.skip(1).subscribe(onNext:{[unowned self] _ in
            self.createHeaderView()
        }).disposed(by: disposeBag)
        
        let loadingState = self.viewModel.outputs.isLoading.asObservable()
            .distinctUntilChanged()
        
        loadingState.subscribe(onNext:{
            isLoading in
            if(isLoading){
                FunctionHelper.showHUD()
            }
            else{
                FunctionHelper.hideHUD()
            }
        }).disposed(by: disposeBag)
        
        //slide show the images
        Observable<Int>.interval(3.0, scheduler: MainScheduler.instance)
            .subscribe(onNext:{[unowned self] _ in
                self.slideShow()
                }
            ).disposed(by: disposeBag)
        
        
        self.tableView?.rx.didScroll.subscribe(onNext:{[unowned self] _ in
            if let paralax = self.tableView?.tableHeaderView as? ParallaxHeaderView{
                paralax.layoutHeaderView(forScrollOffset: self.tableView!.contentOffset)
            }
        }).disposed(by: disposeBag)
        
        
        //fetch merchant Detail
        refreshMerchant.onNext()
        
    }
    
    
    func goToModalDetail(){
        self.viewModel.detailModalTrigger.onNext(self.merchant)
    }
    
    func openLink(_ link:String){
        
        if let url = URL(string: link){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func refreshTableContent(){
        
        var array:[CellModel] = []
        
        array.append(CellModel("buttonsCell", content: self.merchant))
        array.append(CellModel("locationCell", content: self.merchant))
        
        if (self.merchant.products != nil){
            array.append(CellModel("segmentCell"))
            if let products = self.merchant.getProductType(state: self.state), products.count > 0{
                let cells = products.map{CellModel("basicCell", content:$0)}
                array.append(contentsOf: cells)
            }
            else{
                array.append(CellModel("redeemEmptyCell"))
            }
        }
        
        tableContent = array
        
    }
    
}

extension DetailVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableContent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model = self.tableContent[indexPath.row]
        
        switch model.identifier {
        case "buttonsCell":
            return 45
        case "locationCell":
            return 60
        case "segmentCell":
            return 40
        case "redeemEmptyCell":
            var sisaTinggi = tableView.frame.size.height - (45 + 60 + 40)
            sisaTinggi = sisaTinggi - tableView.frame.size.width*6/14 //headerView
            sisaTinggi = sisaTinggi > 165 ? sisaTinggi : 165
            return sisaTinggi
        default:
            return UITableViewAutomaticDimension
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.tableContent[indexPath.row]
        let identifier = model.identifier
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: identifier)!
        cell.selectionStyle = .none
        
        if (identifier == "buttonsCell"){
            var view = cell.viewWithTag(1)
            if (view == nil){
                if let merchant = model.content as? Merchant{
                    view = self.createSocialButtonView(cell: cell,merchant:merchant)
                }
            }
        }
        else if(identifier == "locationCell"){
            
            let addressLbl = cell.viewWithTag(1) as? UILabel
            let cityLbl = cell.viewWithTag(2) as? UILabel
            
            if let merchant = model.content as? Merchant{
                addressLbl?.text = merchant.place?.address
                cityLbl?.text = "\(merchant.location_id)"
            }
            
        }
        else if (identifier == "segmentCell"){
            
            if let offerBut = cell.viewWithTag(1) as? EmveepRegularButton,let monthBut = cell.viewWithTag(2) as? EmveepRegularButton{
                
                offerBut.handleControlEvent(event: .touchUpInside, block: {[weak self] _ in self?.state = .NORMAL})
                
                monthBut.handleControlEvent(event: .touchUpInside, block: {[weak self] _ in self?.state = .MONTHLY})
                
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
        else if(identifier == "basicCell"){
            if let offerDic = model.content as? NSDictionary{
                let offer = Offer(dictionary: offerDic)
                let object = offer.convertToCellObject()
                
                if let cell = cell as? BasicViewCell{
                    cell.fillCellWithObject(object: object)
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}


//MARK: Create Custom View
extension DetailVC{
    
    func createSocialButtonView(cell:UITableViewCell, merchant:Merchant)->UIView{
        
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
        
        if let url = merchant.merchant_detail?.additional_details?["instagram"]{
            let dic = ["type":"instagram","image":"instagram","link":url]
            socialButtons.append(dic)
        }
        
        if let url = merchant.merchant_detail?.additional_details?["facebook"]{
            let dic = ["type":"facebook","image":"facebook","link":url]
            socialButtons.append(dic)
        }
        
        if let url = merchant.merchant_detail?.additional_details?["web"]{
            let dic = ["type":"web","image":"web","link":url]
            socialButtons.append(dic)
        }
        
        var buttonArray : [UIButton] = []
        let buttonInset = UIEdgeInsetsMake(8,8,8,8)
        
        for dic:[String:Any] in socialButtons{
            let button = EmveepRegularButton()
            button.setImage(UIImage(named: dic["image"] as! String), for:.normal)
            button.contentEdgeInsets = buttonInset
            
            button.handleControlEvent(event: .touchUpInside, block: { [weak self] _ in
                if let urlString = dic["link"] as? String
                {self?.openLink(urlString)}
            })
            
            buttonArray.append(button)
        }
        
        let socialButtonContainer = self.createViewFromButtonArray(buttonArray)
        
        var rightButtons : [UIButton] = []
        
        if let phones = merchant.merchant_detail?.additional_details?["phone"]{
            let phoneButton = EmveepRegularButton()
            phoneButton.setImage(UIImage(named: "phone"), for: .normal)
            phoneButton.contentEdgeInsets = buttonInset
            
            phoneButton.handleControlEvent(event: .touchUpInside, block: { _ in
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
        locButton.handleControlEvent(event: .touchUpInside, block: {[weak self] _ in
            
            if let lat = merchant.place?.coordinate?["lat"], let long = merchant.place?.coordinate?["lng"]{
                let urlString = "https://maps.google.com/?daddr=\(lat),\(long)&directionsmode=driving"
                self?.openLink(urlString)
            }
            
        })
        
        rightButtons.append(locButton)
        
        if let menus = merchant.merchant_detail?.additional_details?["menu"]{
            let menuButton = EmveepRegularButton()
            menuButton.setImage(UIImage(named: "menu"), for: .normal)
            menuButton.contentEdgeInsets = buttonInset
            
            menuButton.handleControlEvent(event: .touchUpInside, block: {[weak self] _ in
                
                if let urlString = menus as? String
                {self?.openLink(urlString)}
                
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
        
        guard let tableView = self.tableView else{
            return
        }
        
        if (tableView.tableHeaderView) != nil{
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
        
        let merchant = self.merchant
        
        let images = merchant.merchant_detail?.images
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
            pageControl!.numberOfPages = count
            pageControl!.isEnabled = false
            pageControl!.currentPage = 0
            view.addSubview(pageControl!)
            
            pageControl!.snp.makeConstraints({ (make) -> Void in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-5)
            })
            
        }
        
        let headerView = ParallaxHeaderView.parallaxHeaderView(withSubView: view)
        
        self.tableView?.tableHeaderView = headerView as! UIView?
        
    }
    
    func setPageControlCurrentPage(){
        
        guard let imageScrollViews = imageScrollView, let pageControl = pageControl else{
            return
        }
        
        let horizontalOffset = imageScrollViews.contentOffset.x
        let screenWidth = self.view.frame.size.width
        
        let page = horizontalOffset/screenWidth
        pageControl.currentPage = Int(page)
        
    }
    
    
    func slideShow(){
        
        if let images = self.merchant.merchant_detail?.images, images.count > 1,let pageControl = pageControl{
            
            var currentPage = pageControl.currentPage
            currentPage = currentPage+1
            
            if(currentPage > images.count-1){
                currentPage  = 0
            }
            
            if let scrollViews = imageScrollView {
                scrollViews.setContentOffset(CGPoint(x: CGFloat(currentPage)*scrollViews.frame.size.width, y: 0), animated: true)
            }
            
            
        }
        
    }
    
}





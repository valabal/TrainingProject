//
//  MainVC.swift
//  Training
//
//  Created by Valbal on 8/21/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainVC: BasicVC{
    
    var viewModel : MainVM!
    
    @IBOutlet var topButton : UIButton?
    @IBOutlet var newButton : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingRightNavButtonWithView(arrayOfUIView: [UIViewController.generateMenuButtonViewWithImage(image: UIImage.init(named: "shutdown"), action:#selector(logOff), target: self)])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func settingNavigationMenu() {
        self.navigationController?.navigationBar.isHidden = false
        self.settingNavBarWithTitle("Merchant List")
    }
    
    override func bindingViews(){
        
        let loadPage:PublishSubject<Void> = PublishSubject<Void>()
        let loadNextPage:PublishSubject<Void> = PublishSubject<Void>()
        
        self.tableView?.addPullToRefreshWithActionHandler {
             loadPage.onNext()
        }
        
        self.tableView?.addInfiniteScrollingWithActionHandler {
            loadNextPage.onNext()
        }
        
        //input
        loadPage.bind(to: self.viewModel.inputs.loadPageTrigger).disposed(by:disposeBag)
        loadNextPage.bind(to: self.viewModel.inputs.loadNextPageTrigger).disposed(by:disposeBag)
        self.rx.viewWillAppear.bind(to: self.viewModel.inputs.viewWillAppearTrigger).disposed(by:disposeBag)
        
        self.topButton?.rx.tap.bind(to: self.viewModel.inputs.loadTopTrigger).disposed(by: disposeBag)
        
        self.newButton?.rx.tap.bind(to: self.viewModel.inputs.loadNewTrigger).disposed(by: disposeBag)
        
        
        //output
        self.viewModel.outputs.isLoading.asObservable().subscribe(onNext:{[weak self] isLoading in
            if (!isLoading) {
                self?.tableView?.stopPullToRefresh()
                self?.tableView?.infiniteScrollingView.stopAnimating()
            }
        }).disposed(by:disposeBag)
        
        self.viewModel.outputs.isHUDLoading.asObservable().subscribe(onNext:{isLoading in
            if(isLoading){
                FunctionHelper.showHUD()
            }
            else{
                FunctionHelper.hideHUD()
            }
        }).disposed(by:disposeBag)
        
        self.viewModel.outputs.contents.asDriver().asObservable().subscribe(onNext:{[weak self] _ in
            self?.tableView?.reloadData()
        }).disposed(by:disposeBag)
        
        self.viewModel.outputs.isComplete.asDriver().asObservable().distinctUntilChanged().skip(1)
            .subscribe(onNext:{[weak self] isComplete in
                self?.tableView?.showsInfiniteScrolling = !isComplete
            }).disposed(by:disposeBag)
        
        self.tableView?.rx.itemSelected
            .subscribe(onNext: { [weak self]indexPath in
                self?.viewModel.inputs.tapped(row : indexPath.row)
            }).disposed(by:disposeBag)
        
        
        self.viewModel.loadHUDTrigger.onNext()
        
    }
    
    func logOff(){
        NotificationCenter.default.post(name: .forceLogout, object: nil)
    }
    
}



extension MainVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.contents.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BasicViewCell  = tableView.dequeueReusableCell(withIdentifier: "basicCell")! as! BasicViewCell
        
        let merchant = self.viewModel.contents.value[indexPath.row]
        let object = merchant.convertToCellObject()
        cell.fillCellWithObject(object: object)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
        
    }
    
    
    
}

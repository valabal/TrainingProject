//
//  BasicViewCell.swift
//  Training
//
//  Created by Valbal on 8/23/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import EVReflection
import SDWebImage
import RxSwift


protocol BasicCellObjectProtocol {
    func convertToCellObject() -> BasicCellObject
}

class BasicCellObject: NSObject{

    var title: String?
    var subTitle: String?
    var descString : String?
    var imageURL : String?
    var other : Any?
    
}

class BasicViewCell : UITableViewCell{

    @IBOutlet var titleLabel : UILabel?
    @IBOutlet var subTitleLabel : UILabel?
    @IBOutlet var descLabel : UILabel?
    @IBOutlet var mainImage : UIImageView?
    @IBOutlet var subImage : UIImageView?
    @IBOutlet var lineView : UIView?
    
    public var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag() // because life cicle of every cell ends on prepare
    }
 
    func fillCellWithObject(object:BasicCellObject){
    
        titleLabel?.setOptionalText(text: object.title)
        subTitleLabel?.setOptionalText(text: object.subTitle)
        descLabel?.setOptionalText(text: object.descString)
        
        if let imageURLString = object.imageURL as String?{
          mainImage?.sd_setImage(with: URL(string:imageURLString))
        }
    
    }
    

}


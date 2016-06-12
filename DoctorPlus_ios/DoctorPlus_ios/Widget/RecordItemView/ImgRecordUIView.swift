//
//  ImgRecordUIView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ImgRecordUIView: UIView {


    @IBOutlet weak var img: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ImgRecordUIView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDatas(recordItem: ComFqHalcyonEntityRecordItem?){
        if recordItem == nil || recordItem?.getPhotos() == nil {
            return
        }
        
        if recordItem?.getPhotos().size() > 0 {
            let list = recordItem!.getPhotos() as JavaUtilArrayList
            ApiSystem.getImageWithComFqHalcyonEntityPhoto(list.getWithInt(0) as! ComFqHalcyonEntityPhoto, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
                let path:NSString? = data as? NSString
                if(path != nil){
                    self.img.image = UITools.getImageFromFile(path!)
                }
            }))
        }
    }
}

//
//  MyQrCodeViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MyQrCodeViewController: BaseViewController{

    @IBOutlet var addView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var QrCode: UIImageView!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("二维码")
        hiddenRightImage(true)
        scrollView.addSubview(addView)
        scrollView.contentSize = CGSizeMake(ScreenWidth, 600)
        let url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=\(ComFqLibToolsConstants.getUser().getUserId())"
        let QrCodeImage = UITools.createQrCode(url, imageview: QrCode)
        QrCode.image = QrCodeImage
        let borderColor = UIColor(red:98/255.0,green:192/255.0,blue:180/255.0,alpha:1)
        UITools.setBorderWithView(1.0, tmpColor: borderColor.CGColor, view: headImage)
        userName.text = "医生  \(ComFqLibToolsConstants.getUser().getName())"
//        UIAlertViewTool.getInstance().showAutoDismisDialog("这是测试")
        let photo:ComFqHalcyonEntityPhoto = ComFqHalcyonEntityPhoto(int: ComFqLibToolsConstants.getUser().getImageId(),withNSString: "")
        headImage.downLoadImageWidthImageId(photo.getImageId(), callback: { (view, path) -> Void in
            let tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "MyQrCodeViewController"
    }
    
       
}

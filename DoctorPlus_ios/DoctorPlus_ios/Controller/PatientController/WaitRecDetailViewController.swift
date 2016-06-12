//
//  WaitRecDetailViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-24.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class WaitRecDetailViewController: BaseViewController {

    
    @IBOutlet weak var ctrlBtn: UIButton!
    @IBOutlet weak var recInfoText: UITextView!
    @IBOutlet weak var contentView: UIView!
    
    var isImageShow = false
    
    var imagesView:BrowserPhotosView!
    
    var recRecord:ComFqHalcyonEntityPracticeRecordAbstract?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        showImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "WaitRecDetailViewController"
    }

    @IBAction func ctrlBtnClick(sender: AnyObject) {
        
        
    }
    
    func showImages(){
        imagesView = BrowserPhotosView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight - 70))
        self.view.addSubview(imagesView)
        imagesView.clearGesture()
        
        let imgList = recRecord?.getImgIds()
        var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
        for var i:Int32 = 0 ; i < imgList!.size() ; i++ {
            let photoRecord = ComFqHalcyonEntityPhotoRecord()
            let imageId = imgList!.getWithInt(i) as! NSNumber
            photoRecord.setImageIdWithInt(imageId.intValue)
            photoRecord.setStateWithInt(ComFqHalcyonEntityPhotoRecord_OCR_STATE_COMPLETE)
            pagePhotoRecords.append(photoRecord)
        }
        if pagePhotoRecords.count > 0 {
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
        }
        
    }
}

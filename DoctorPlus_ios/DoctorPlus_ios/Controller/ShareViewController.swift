//
//  ShareViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ShareViewController: BaseViewController,ISSViewDelegate,ISSShareViewDelegate{

    @IBOutlet weak var sinaBtn: UIButton!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var friendCircle: UIButton!
    @IBOutlet weak var wxBtn: UIButton!
    @IBOutlet weak var adsdsd: UILabel!
    @IBOutlet weak var erweimaImageView: UIImageView!
    @IBOutlet weak var xinlangweiboLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var wxpyqLabel: UILabel!
    @IBOutlet weak var wxhyLabel: UILabel!
    var url:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        xinlangweiboLabel.numberOfLines = 5
        messageLabel.numberOfLines = 5
        wxpyqLabel.numberOfLines = 5
        wxhyLabel.numberOfLines = 5
        xinlangweiboLabel.text = "新\n浪\n微\n博\n"
        messageLabel.text = "手\n机\n短\n信\n"
        wxpyqLabel.text = "微\n信\n朋\n友\n圈"
        wxhyLabel.text = "微\n信\n好\n友\n"
        xinlangweiboLabel.textAlignment = NSTextAlignment.Center
        messageLabel.textAlignment = NSTextAlignment.Center
        wxpyqLabel.textAlignment = NSTextAlignment.Center
        wxhyLabel.textAlignment = NSTextAlignment.Center
        url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=\(ComFqLibToolsConstants.getUser().getUserId())"
        let QrCodeImage = UITools.createQrCode(url!, imageview: erweimaImageView)
        erweimaImageView.image = QrCodeImage
        
        for i in 11..<15 {
            let btn = self.view.viewWithTag(i) as! UIButton
            btn.addTarget(self, action: "shareBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func shareBtnClick(sender:UIButton) {
        let tag  = sender.tag
        var shareType:ShareType?
        switch tag {
        case 11:
            shareType = ShareTypeSinaWeibo
        case 12:
            shareType = ShareTypeSMS
        case 13:
            shareType = ShareTypeWeixiTimeline
        case 14:
            shareType = ShareTypeWeixiSession
        default:
            shareType = ShareTypeSinaWeibo
        }
        
        customShareSdkInterface(shareType!, btn: sender)
    }
    
    func customShareSdkInterface(shareType:ShareType,btn:UIButton) {
        let img = UIImage(named:"icon_close_doc_plus")
        let shareImg = ShareSDK.pngImageWithImage(img)
        switch shareType.rawValue {
        case ShareTypeWeixiTimeline.rawValue,ShareTypeWeixiSession.rawValue:
            let content = ShareSDK.content("轻松地积累病历，高效地管理患者，为医生自由助力。点击进入下载页面", defaultContent: "默认分享内容，没内容时显示", image: shareImg , title: "医加，助力好医生。", url: url, description: nil, mediaType: SSPublishContentMediaTypeApp)
            let mAuthOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
            ShareSDK.shareContent(content, type:shareType, authOptions: mAuthOptions, statusBarTips: false, result: { (shareType, state, statusInfo, info, end) -> Void in
                if state.rawValue == SSPublishContentStateSuccess.rawValue {
                    
                }else {
                    print("分享失败！！！")
                }
            })
        case ShareTypeSinaWeibo.rawValue,ShareTypeSMS.rawValue:
            let publishContent = ShareSDK.content("医加，助力好医生。轻松地积累病历，高效地管理患者，为医生自由助力。下载地址："+url!, defaultContent: "", image: nil, title: nil, url: nil, description: "", mediaType: SSPublishContentMediaTypeText)
            var authOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
            ShareSDK.showShareViewWithType(shareType, container: nil, content: publishContent, statusBarTips: false, authOptions: nil, shareOptions: ShareSDK.defaultShareOptionsWithTitle(nil, oneKeyShareList: NSArray.defaultOneKeyShareList(), qqButtonHidden: false, wxSessionButtonHidden: false, wxTimelineButtonHidden: false, showKeyboardOnAppear: false, shareViewDelegate: self, friendsViewDelegate: self, picViewerViewDelegate: nil), result: { (shareType, state, info, error, end) -> Void in
                
                if state.rawValue == SSPublishContentStateSuccess.rawValue {
                    
                }else {
                    print("分享失败！！！")
                }
            })

        default:
           return
        }
    }
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func getXibName() -> String {
        return "ShareViewController"
    }
}

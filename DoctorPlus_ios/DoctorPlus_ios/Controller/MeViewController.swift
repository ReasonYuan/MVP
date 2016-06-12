//
//  MeViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15-7-17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MeViewController: BaseViewController,ISSViewDelegate,ISSShareViewDelegate{

    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var QrCode: UIImageView!
    @IBOutlet weak var settingBtn:UIButton!
    @IBOutlet weak var shareBtn:UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var sexView: UIView!
    @IBOutlet weak var sexIcon: UIImageView!
    var url:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("个人中心")
        hiddenRightImage(true)
        hiddenLeftImage(true)
        UITools.setBtnBackgroundColor(settingBtn,selectedColor: Color.gray,unSelectedColor: UIColor.whiteColor(),disabledColor: UIColor.whiteColor())
        UITools.setBtnBackgroundColor(shareBtn,selectedColor: Color.gray,unSelectedColor: UIColor.whiteColor(),disabledColor: UIColor.whiteColor())
        url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=\(ComFqLibToolsConstants.getUser().getUserId())"
        let QrCodeImage = UITools.createQrCode(url!, imageview: QrCode)
        
        UITools.setBorderWithView(1.0, tmpColor: UIColor.grayColor().CGColor, view: headBtn)
        UITools.setRoundBounds(50.0, view: headBtn)
        UITools.setRoundBounds(5.0, view: bottomView)
        UITools.setRoundBounds(5.0, view: centerView)
        UITools.setRoundBounds(5.0, view: topView)
        UITools.setRoundBounds(12.5, view: sexView)
        
        QrCode.image = QrCodeImage

        let gender = ComFqLibToolsConstants.getUser().getGenderStr()
        if gender == "男" {
            sexIcon.image = UIImage(named: "icon_man.png")
        }else {
            sexIcon.image = UIImage(named: "icon_female.png")
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
        let name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserHeadName()
        let getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
        if(getSuccess != nil){
            headBtn.setBackgroundImage(getSuccess, forState: UIControlState.Normal)
        }else{
            headBtn.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                let  head = view as? UIButton
                head?.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
            })
            
        }
        doctorName.text = ComFqLibToolsConstants.getUser().getName()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "MeViewController"
    }
    
    @IBAction func shareClick(sender: AnyObject) {
//        self.navigationController?.pushViewController(ShareViewController() , animated: true)
//    [ComFqLibToolsConstants.getShareTextWithInt(<#type: Int32#>)]
        let img = UIImage(named:"appIcon_80")
        let shareImg = ShareSDK.pngImageWithImage(img)
        var shareList = [ShareTypeWeixiSession,ShareTypeWeixiTimeline]
        let content = ShareSDK.content("HiTales Practice致力于整合医疗数据，提升医生临床和研究效率，为病人提供更好的治疗。",
            defaultContent: "默认分享内容，没内容时显示",
            image: shareImg ,
            title: "HiTales Practice--Data Driven Health",
            url: url,
            description: nil,
            mediaType: SSPublishContentMediaTypeNews)
        let mAuthOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
        ShareSDK.showShareActionSheet(nil, shareList: nil, content: content, statusBarTips: false, authOptions: mAuthOptions, shareOptions: nil) { (type, state, statusInfo, info, end) -> Void in
            if state.rawValue == SSPublishContentStateSuccess.rawValue {
                
            }else {
                print("分享失败！！！")
            }
        }
    }
    
    func shareView(sender: AnyObject) {
        
    }

    @IBAction func settingClick(sender: AnyObject) {
        self.navigationController?.pushViewController(SettingViewController() , animated: true)
    }

    @IBAction func myInfoClick(sender: AnyObject) {
        self.navigationController?.pushViewController(UserProfileViewController() , animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

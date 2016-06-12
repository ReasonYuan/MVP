//
//  VisitorMeViewController.swift
//  
//
//  Created by Nan on 15/8/11.
//
//

import UIKit

class VisitorMeViewController: BaseViewController,ISSViewDelegate,ISSShareViewDelegate {
     var url:String?

    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("我")
        hiddenRightImage(true)
        hiddenLeftImage(true)
        
        url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=\(ComFqLibToolsConstants.getUser().getUserId())"
        //url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=0)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  getXibName() -> String {
    return "VisitorMeViewController"
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        let img = UIImage(named:"appIcon_80")
        let shareImg = ShareSDK.pngImageWithImage(img)
        var shareList = [ShareTypeWeixiSession,ShareTypeWeixiTimeline]
        let content = ShareSDK.content("HiTales Practice致力于整合医疗数据，提升医生临床和研究效率，为病人提供更好的治疗。",
            defaultContent: "默认分享内容，没内容时显示", image: shareImg ,
            title: "HiTales Practice--Data Driven Health",
            url: url, description: nil, mediaType: SSPublishContentMediaTypeApp)
        let mAuthOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
        ShareSDK.showShareActionSheet(nil, shareList: nil, content: content, statusBarTips: false, authOptions: mAuthOptions, shareOptions: nil) { (type, state, statusInfo, info, end) -> Void in
            if state.rawValue == SSPublishContentStateSuccess.rawValue {
                
            }else {
                print("分享失败！！！")
            }
        }
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        let loginViewController:LoginViewController = LoginViewController(nibName:"LoginViewController",bundle:nil)
        loginViewController.isb = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
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

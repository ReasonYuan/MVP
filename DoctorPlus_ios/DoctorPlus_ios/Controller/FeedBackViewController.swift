//
//  FeedBackViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FeedBackViewController: BaseViewController,UITextViewDelegate,ComFqHalcyonLogic2UploadFeedBackLogic_UploadFeedBackLogicInterface {
    var dialog:CustomIOS7AlertView?
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var length: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("反馈意见")
        hiddenRightImage(true)
        length.text = "0"
        textView.delegate = self
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sendBtn, isOpposite: false)
        sendBtn.enabled = false
        
    }
    
    func textViewDidChange(textView: UITextView) {
        length.text = NSString(format: "%d", textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) as String
        if textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0{
            sendBtn.enabled = false
        }else{
            sendBtn.enabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "FeedBackViewController"
    }
    
    @IBAction func send(sender: AnyObject) {
        ComFqHalcyonLogic2UploadFeedBackLogic(comFqHalcyonLogic2UploadFeedBackLogic_UploadFeedBackLogicInterface:self, withNSString: textView.text)
        dialog = UIAlertViewTool.getInstance().showLoadingDialog("正在提交反馈意见...")
        sendBtn.enabled = false
    }
    
    func onErrorReturnWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        dialog?.close()
        (UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("提交反馈意见失败！", width: 210, height: 120)
        sendBtn.enabled = true
    }
    
    func onDaraReturnWithInt(responseCode: Int32, withNSString msg: String!) {
        dialog?.close()
        (UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("提交意见成功，谢谢参与！", width: 210, height: 120)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        
    }
    
    
    
}

//
//  PersonalDescriptionViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-30.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PersonalDescriptionViewController: BaseViewController,UITextViewDelegate {


    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var conform: UIButton!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        setTittle("个人简介")
        textView.delegate = self
//        UITools.setButtonWithColor(ColorType.EMERALD, btn: conform, isOpposite:false)
        textView.text = ComFqLibToolsConstants.getUser().getDescription()
        var size = 100 - NSString(string: ComFqLibToolsConstants.getUser().getDescription()).length
        //500 - textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
//        sizeLabel.text = "\(size)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let description = textView.text
        if  description.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            ComFqLibToolsConstants.getUser().setDescriptionWithNSString(description)
            ComFqLibToolsUserProfileManager.instance().reqModyDes()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "PersonalDescriptionViewController"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
   
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.view.endEditing(true)
//    }
    
    func textViewDidChange(textView: UITextView) {
        var size = 100 - NSString(string: textView.text).length
        //when the text is longer than 500
        if (100 - NSString(string: textView.text).length) < 0 {
            let str = textView.text
            let index1 = str.endIndex.advancedBy(100 - NSString(string: textView.text).length)
            self.textView.text = str.substringToIndex(index1)
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
//    @IBAction func conformClick(sender: AnyObject) {
//        var description = textView.text
//        if  description.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
//            ComFqLibToolsConstants.getUser().setDescriptionWithNSString(description)
//            ComFqLibToolsUserProfileManager.instance().reqModyDes()
//            self.navigationController?.popViewControllerAnimated(true)
//        }
//    }
    
   
}

//
//  AboutDocPlusViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class AboutDocPlusViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    var isProtocol = false
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setTittle("关于医加")
        hiddenRightImage(true)
        if isProtocol == false{
         titleLabel.text = "关于HiTales"  
        let path:NSString = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("about_doc_plus.txt")
        let url:NSURL = NSURL.fileURLWithPath(path as String)
        let data:NSData = NSData(contentsOfURL: url)!
        var str:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let json:NSMutableDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableDictionary
        let detail:NSString = json.objectForKey("aboutPlus") as! NSString
        detailTextView.text = detail as String
   
        }else{
            titleLabel.text = "注册协议"
            let path:NSString = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("register_protocol.txt")
            let url:NSURL = NSURL.fileURLWithPath(path as String)
            let data:NSData = NSData(contentsOfURL: url)!
            let str:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            let json:NSMutableDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableDictionary
            let detail:NSString = json.objectForKey("registerProtocol") as! NSString
            detailTextView.text = detail as String

        }
         self.scrollView.contentSize = CGSizeMake(ScreenWidth, detailTextView.frame.origin.y + detailTextView.contentSize.height + 20)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailTextView.scrollRectToVisible(CGRectMake(0, 0, detailTextView.frame.size.width, detailTextView.frame.size.height), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    override func getXibName() -> String {
        return "AboutDocPlusViewController"
    }


}

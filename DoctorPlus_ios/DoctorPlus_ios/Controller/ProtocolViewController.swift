//
//  ProtocolViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/4/27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ProtocolViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setTittle("关于医加")
        hiddenRightImage(true)
        var path:NSString = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("about_doc_plus.txt")
        var url:NSURL = NSURL.fileURLWithPath(path as String)
        var data:NSData = NSData(contentsOfURL: url)!
        var str:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        var json:NSMutableDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSMutableDictionary
        var detail:NSString = json.objectForKey("aboutPlus") as! NSString
        detailTextView.text = detail as String
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
        return "ProtocolViewController"
    }
    
    
}


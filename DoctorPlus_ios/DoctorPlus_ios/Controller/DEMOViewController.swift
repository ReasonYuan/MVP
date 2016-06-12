//
//  DEMOViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-10.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class DEMOViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate {

   
    @IBOutlet weak var testBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var tabView:UITableView  = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSizeMake(ScreenWidth*3, ScreenHeight)
        tabView.frame = CGRectMake(0, 0, ScreenWidth - 0, ScreenHeight)
        scrollView.addSubview(tabView)
        tabView.registerNib(UINib(nibName: "ContactsTableViewCell", bundle:nil), forCellReuseIdentifier: "ContactsTableViewCell")
        tabView.delegate = self
        tabView.dataSource = self
        testBtn.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestrue:"))
    }
    
    func panGestrue(panGesture:UIPanGestureRecognizer){
        let curPoint = panGesture.locationInView(self.view)
        self.testBtn.center = curPoint
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        ContactsTableViewCell
        let cellIdentifier: String = "programmaticCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? MGSwipeTableCell
        if cell == nil{
            cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let view =  NSBundle.mainBundle().loadNibNamed("ContactsTableViewCell", owner: self, options: nil)[0] as! ContactsTableViewCell
        view.frame = CGRectMake(0, 0, ScreenWidth, 44)
        view.contentView.frame = CGRectMake(0, 0, ScreenWidth, 44)
        cell?.contentView.addSubview(view)
        cell?.delegate = self
        
        cell?.rightSwipeSettings.transition = MGSwipeTransitionStatic
        cell?.rightExpansion.buttonIndex = -1
        cell?.rightExpansion.fillOnTrigger = true
        cell?.rightButtons = createRightButtons(4) as [AnyObject]
        return cell!
    }
    
    func createRightButtons(count:NSInteger) -> NSArray {
        let result = NSMutableArray()
        var tittle = ["测试1","测试1","测试1"]
        var colors = [UIColor.redColor(),UIColor.blueColor(),UIColor.blackColor()]
        for i in 0..<count {
//            var button = MGSwipeButton(title: tittle[i], backgroundColor: colors[i], callback: { (cell) -> Bool in
//                return true
//            })
            var button:MGSwipeButton?
            if i == 1{
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: UIColor.greenColor())
            }
            
            if i == 2 {
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: UIColor.blueColor())
            }
            
            if i == 0{
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: UIColor.blackColor())
            }
            
            if i == 3 {
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: UIColor.grayColor())
            }
            
            result.addObject(button!)
        }
        return result
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
    }
   
}

//
//  PatientSearchViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientSearchViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabView: UITableView!
    var mType :Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tabView.registerNib(UINib(nibName: "PatientSearchPatientCell", bundle: nil), forCellReuseIdentifier: "PatientSearchPatientCell")
        tabView.registerNib(UINib(nibName: "PatientSearchRecordCell", bundle: nil), forCellReuseIdentifier: "PatientSearchRecordCell")
        setTittle("探索")
        hiddenRightImage(true)
        tabView.allowsSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    override func getXibName() -> String {
        return "PatientSearchViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            return 2
        }else{
            return 3
        }
       
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 1 {
            return 44.0
        }else{
            return 80.0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        print(row)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let cellIdentifier: String = "programmaticCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? MGSwipeTableCell
        if cell == nil{
            cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if section == 1 {
            let view =  NSBundle.mainBundle().loadNibNamed("PatientSearchRecordCell", owner: self, options: nil)[0] as! PatientSearchRecordCell
            view.frame = CGRectMake(0, 0, ScreenWidth, 44)
            view.contentView.frame = CGRectMake(0, 0, ScreenWidth, 44)
            cell?.contentView.addSubview(view)
            cell?.delegate = self
            view.tag = indexPath.row
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "patientCellTapGesture:"))
            cell?.rightSwipeSettings.transition = MGSwipeTransitionStatic
            cell?.rightExpansion.buttonIndex = -1
            cell?.rightExpansion.fillOnTrigger = true
            cell?.rightButtons = createRightButtons(3) as [AnyObject]
        
            return cell!
        }else{
            let view =  NSBundle.mainBundle().loadNibNamed("PatientSearchPatientCell", owner: self, options: nil)[0] as! PatientSearchPatientCell
            view.frame = CGRectMake(0, 0, ScreenWidth, 80)
            view.contentView.frame = CGRectMake(0, 0, ScreenWidth, 80)
            cell?.contentView.addSubview(view)
            view.content.numberOfLines = 0
            view.content.font = UIFont.systemFontOfSize(13.0)
            view.content.text = "你是个都hi四点就爱家的家居第九哦交大交大刻录机空间看得见阿克拉结阿克拉结来看空间看了解到快进阿克拉结来看空间看了解到快进来看空间看了解到快进来"
            view.content.sizeToFit()
            view.tag = indexPath.row
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "recordCellTapGesture:"))
            cell?.delegate = self
            cell?.rightSwipeSettings.transition = MGSwipeTransitionStatic
            cell?.rightExpansion.buttonIndex = -1
            cell?.rightExpansion.fillOnTrigger = true
            cell?.rightButtons = createRightButtons(4) as [AnyObject]
            
            UITools.setRoundBounds(23, view: view.head)
            UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: view.head)
            return cell!
        }
       
    }
    
    /**病案cell的点击事件**/
    func patientCellTapGesture(cellTapGesture:UITapGestureRecognizer){
        let cell = cellTapGesture.view
        self.view.endEditing(true)
        print(cell!.tag)
    }
    
     /**记录cell的点击事件**/
    func recordCellTapGesture(cellTapGesture:UITapGestureRecognizer){
        let cell = cellTapGesture.view
        self.view.endEditing(true)
        print(cell!.tag)
    }
    
    func createRightButtons(count:NSInteger) -> NSArray {
        let result = NSMutableArray()
        var tittle = ["测试1","测试1","测试1"]
        for i in 0..<count {
            var button:MGSwipeButton?
            if i == 1{
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: Color.color_violet)
            }
            
            if i == 2 {
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: Color.color_violet)
            }
            
            if i == 0{
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: Color.color_violet)
            }
            
            if i == 3 {
                button = MGSwipeButton(title: nil, icon: UIImage(named: "btn_del_patient.png"), backgroundColor: Color.color_violet)
            }
            
            
            result.addObject(button!)
        }
        return result
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let row = tabView.indexPathForCell(cell!)!.row
        let section = tabView.indexPathForCell(cell!)!.section
        if direction.rawValue == MGSwipeDirectionRightToLeft.rawValue {
            if section == 0 {
                switch index {
                case 0:
                    print("\(section)---\(row)---\(index)")
                case 1:
                    print("\(section)---\(row)---\(index)")
                case 2:
                    print("\(section)---\(row)---\(index)")
                case 3:
                    print("\(section)---\(row)---\(index)")
                default:
                    return true
                }
                
            }else if section == 1 {
                switch index {
                case 0:
                    print("\(section)---\(row)---\(index)")
                case 1:
                    print("\(section)---\(row)---\(index)")
                case 2:
                    print("\(section)---\(row)---\(index)")
                default:
                    return true
                }
                
            }
            
        }
        return true
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = PatientSearchCellFooterView(frame: CGRectMake(0, 0, ScreenWidth, 40))
        view.tag = section
        if section == 1 {
            view.more.hidden = true
        }else{
          view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "footTapGesture:"))
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = PatientSearchCellHeadView(frame: CGRectMake(0, 0, ScreenWidth, 40))
        return view
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func footTapGesture(tapGesture:UITapGestureRecognizer){
        let curView = tapGesture.view
        let tag = curView!.tag as Int
        let control = MorePatientViewController()
        switch tag {
        case 0:
            /**病案查看更多**/
            print(tag)
            control.isPatient = true
            self.navigationController?.pushViewController(control, animated: true)
        case 1:
            /**记录查看更多**/
            print(tag)
            control.isPatient = false
            self.navigationController?.pushViewController(control, animated: true)
        default:
            return
        }
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchOnClick()
            return false
        }
        return true
    }
    
    func searchOnClick(){
        self.view.endEditing(true)
        print("\(searchBar.text)")
    }
    
}

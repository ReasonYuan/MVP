//
//  AllRecordPhotoViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-6-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class AllRecordPhotoViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tabView: UITableView!
    var mTypes = JavaUtilArrayList()
    var isEditMode = false
    var dialog:CustomIOS7AlertView?
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        setRightBtnTittle("全部上传")
        tabView.registerNib(UINib(nibName: "AllRecordCell", bundle:nil), forCellReuseIdentifier: "AllRecordCell")
        tabView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewOutSideClick:"))
    }
    
    func tabViewOutSideClick(gesture:UITapGestureRecognizer){
        if  isEditMode {
            setEditMode(false)
            tabView.reloadData()
        }
        
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        if ComFqLibToolsConstants.getUser().isOnlyWifi() && !isNetWorkOK() {
            dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("请连接wifi或者关闭设置中“仅wifi状态下上传病历”", target: self, actionOk: "dialogOK:")
        }else {
            let index:Int! = self.navigationController?.viewControllers.count
            let controller: UIViewController = self.navigationController!.viewControllers[index - 4]
            self.navigationController?.popToViewController(controller, animated: true)
        }
       
    }
    
    func dialogOK(sender:UIButton){
        dialog?.close()
    }
    
    /*!
    * 判断是否有网络连接
    */
    func isNetWorkOK()->Bool{

        return Tools.isWifiConnect()
    }
    
    override func viewWillAppear(animated: Bool) {
        mTypes = ComFqLibRecordSnapPhotoManager.getInstance().getTypes()
        tabView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "AllRecordPhotoViewController"
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "AllRecordCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? AllRecordCell
        if cell == nil{
            cell = AllRecordCell()
        }
        var row =  indexPath.row
        
        let longClick1 = UILongPressGestureRecognizer(target: self, action: "LongClick1:")
        let longClick2 = UILongPressGestureRecognizer(target: self, action: "LongClick2:")
        let longClick3 = UILongPressGestureRecognizer(target: self, action: "LongClick3:")
        let longClick4 = UILongPressGestureRecognizer(target: self, action: "LongClick4:")
        cell?.btn1.setTitle("", forState: UIControlState.Normal)
        cell?.btn2.setTitle("", forState: UIControlState.Normal)
        cell?.btn3.setTitle("", forState: UIControlState.Normal)
        cell?.btn4.setTitle("", forState: UIControlState.Normal)
        cell?.btn1.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
        cell?.btn2.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
        cell?.btn3.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
        cell?.btn4.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
        let oneType = (mTypes.getWithInt(Int32(indexPath.section)) as! ComFqHalcyonUimodelsOneType)
        let list = oneType.getAllPhotos()
        let size = list.size()
        let tittleStr = ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(oneType.getType())
        if size < 4 {
            switch size {
            case 0:
                cell?.view1.hidden = false
                cell?.view2.hidden = true
                cell?.btn1.setBackgroundImage(UIImage(named: "btn_cretifi_add_normal.png"), forState: UIControlState.Normal)
                cell?.view3.hidden = true
                cell?.view4.hidden = true
                
                if isEditMode {
                    cell?.icon1.hidden = true
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }else{
                    cell?.icon1.hidden = true
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }
            case 1:
                if (mTypes.getWithInt(Int32(indexPath.section)) as! ComFqHalcyonUimodelsOneType).getType() == ComFqLibRecordRecordConstants_TYPE_EXAMINATION {
                    cell?.view1.hidden = false
                    cell?.view2.hidden = true
                    cell?.view3.hidden = true
                    cell?.view4.hidden = true
                   
                }else{
                    cell?.view1.hidden = false
                    cell?.view2.hidden = false
                    cell?.view3.hidden = true
                    cell?.btn2.setBackgroundImage(UIImage(named: "btn_cretifi_add_normal.png"), forState: UIControlState.Normal)
                    cell?.view4.hidden = true
                    
                }
               cell?.btn1.setTitle(tittleStr, forState: UIControlState.Normal)
               cell?.btn1.addGestureRecognizer(longClick1)
                if isEditMode {
                    cell?.icon1.hidden = false
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }else{
                    cell?.icon1.hidden = true
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }
            case 2:
                cell?.view1.hidden = false
                cell?.view2.hidden = false
                cell?.view3.hidden = false
                cell?.btn3.setBackgroundImage(UIImage(named: "btn_cretifi_add_normal.png"), forState: UIControlState.Normal)
                cell?.view4.hidden = true
                
                cell?.btn1.setTitle(tittleStr, forState: UIControlState.Normal)
                cell?.btn2.setTitle(tittleStr, forState: UIControlState.Normal)
                cell?.btn1.addGestureRecognizer(longClick1)
                cell?.btn2.addGestureRecognizer(longClick2)
                if isEditMode {
                    cell?.icon1.hidden = false
                    cell?.icon2.hidden = false
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }else{
                    cell?.icon1.hidden = true
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }
            case 3:
                cell?.view1.hidden = false
                cell?.view2.hidden = false
                cell?.view3.hidden = false
                cell?.btn4.setBackgroundImage(UIImage(named: "btn_cretifi_add_normal.png"), forState: UIControlState.Normal)
                cell?.view4.hidden = false
                cell?.btn1.addGestureRecognizer(longClick1)
                cell?.btn2.addGestureRecognizer(longClick2)
                cell?.btn3.addGestureRecognizer(longClick3)
                cell?.btn1.setTitle(tittleStr, forState: UIControlState.Normal)
                cell?.btn2.setTitle(tittleStr, forState: UIControlState.Normal)
                cell?.btn3.setTitle(tittleStr, forState: UIControlState.Normal)
                if isEditMode {
                    cell?.icon1.hidden = false
                    cell?.icon2.hidden = false
                    cell?.icon3.hidden = false
                    cell?.icon4.hidden = true
                }else{
                    cell?.icon1.hidden = true
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }
            default:
                cell?.view1.hidden = true
                cell?.view2.hidden = true
                cell?.view3.hidden = true
                cell?.view4.hidden = true
                if isEditMode {
                    cell?.icon1.hidden = false
                    cell?.icon2.hidden = false
                    cell?.icon3.hidden = false
                    cell?.icon4.hidden = false
                }else{
                    cell?.icon1.hidden = true
                    cell?.icon2.hidden = true
                    cell?.icon3.hidden = true
                    cell?.icon4.hidden = true
                }
            }
        
        }else{
            cell?.view1.hidden = false
            cell?.view2.hidden = false
            cell?.view3.hidden = false
            cell?.view4.hidden = false
            cell?.btn1.addGestureRecognizer(longClick1)
            cell?.btn2.addGestureRecognizer(longClick2)
            cell?.btn3.addGestureRecognizer(longClick3)
            cell?.btn4.addGestureRecognizer(longClick4)
            cell?.btn1.setTitle(tittleStr, forState: UIControlState.Normal)
            cell?.btn2.setTitle(tittleStr, forState: UIControlState.Normal)
            cell?.btn3.setTitle(tittleStr, forState: UIControlState.Normal)
            cell?.btn4.setTitle(tittleStr, forState: UIControlState.Normal)
            if isEditMode {
                cell?.icon1.hidden = false
                cell?.icon2.hidden = false
                cell?.icon3.hidden = false
                cell?.icon4.hidden = false
            }else{
                cell?.icon1.hidden = true
                cell?.icon2.hidden = true
                cell?.icon3.hidden = true
                cell?.icon4.hidden = true
            }
        }
        cell?.btn1.tag = 0
        cell?.btn2.tag = 1
        cell?.btn3.tag = 2
        cell?.btn4.tag = 3
        
        
        let section = indexPath.section
        let mTag1 = "\(section)\(cell!.btn1.tag)"
        let mTag2 = "\(section)\(cell!.btn2.tag)"
        let mTag3 = "\(section)\(cell!.btn3.tag)"
        let mTag4 = "\(section)\(cell!.btn4.tag)"
        cell?.btn1.tag = Int(mTag1)!
        cell?.btn2.tag = Int(mTag2)!
        cell?.btn3.tag = Int(mTag3)!
        cell?.btn4.tag = Int(mTag4)!
        cell?.btn1.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.btn2.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.btn3.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.btn4.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell!
    }
    
    func btnClick(sender:UIButton){
        print("\(sender.tag)")
        
        let tagStr:NSString = "\(sender.tag)"
        var row:NSString = ""
        var section:NSString = ""
        let length:Int = tagStr.length
        if  length < 2 {
            row = tagStr
            section = "0"
        }else {
            row = tagStr.substringFromIndex(tagStr.length - 1)
            section = tagStr.substringToIndex(tagStr.length - 1)
        }
        let currentRow =  row.integerValue
        let currentSection = section.integerValue
        print("---currentSection-----\(section) -----currentRow------\(row)")
        let list = (mTypes.getWithInt(Int32(currentSection)) as! ComFqHalcyonUimodelsOneType).getAllPhotos()
        let size = list.size()
        if isEditMode {
            if Int(size) == currentRow {
                setEditMode(false)
                tabView.reloadData()
            }else{
                deleteRecordPhoto(mTypes.getWithInt(Int32(currentSection)) as? ComFqHalcyonUimodelsOneType, index:Int32(currentRow))
            }
        }else {
            if Int(size) == currentRow {
               //调拍照
                 ComFqLibRecordSnapPhotoManager.getInstance().setCurrentIndexWithInt(Int32(currentSection))
                let index:Int! = self.navigationController?.viewControllers.count
                let controller: UIViewController = self.navigationController!.viewControllers[index - 3]
                self.navigationController?.popToViewController(controller, animated: true)
            }else{
                let controller = SnapItemPhotoReviewViewController()
                controller.typeTitle = sender.titleLabel?.text ?? ""
                controller.photoList = list
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
    }
    
    func LongClick1(gesture:UILongPressGestureRecognizer){
         print("编辑模式1")
        setEditMode(true)
        tabView.reloadData()
        
    }
    
    func LongClick2(gesture:UILongPressGestureRecognizer){
        print("编辑模式2")
        setEditMode(true)
        tabView.reloadData()
        
    }
    
    func LongClick3(gesture:UILongPressGestureRecognizer){
        print("编辑模式3")
        setEditMode(true)
        tabView.reloadData()
        
    }
    
    func LongClick4(gesture:UILongPressGestureRecognizer){
        print("编辑模式4")
        setEditMode(true)
        tabView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let list = (mTypes.getWithInt(Int32(section)) as! ComFqHalcyonUimodelsOneType).getAllPhotos()
        let size = list.size()
        
        let mView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 30))
        mView.backgroundColor = UIColor(red: 212/250.0, green:  212/250.0, blue:  212/250.0, alpha: 1)
        
        let label = UILabel(frame: CGRectMake(30, 0, 100, 20))
        label.text = "第\(section + 1)份"
        label.font = UIFont.systemFontOfSize(13.0)
        
        let moreBtn = UIButton(frame: CGRectMake(ScreenWidth - 100, 0, 100, 20))
        moreBtn.setTitle("查看更多", forState: UIControlState.Normal)
        moreBtn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
        moreBtn.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        moreBtn.tag = section
        if size >= 4{
            moreBtn.hidden = false
        }else{
            moreBtn.hidden = true
        }
        
        moreBtn.addTarget(self, action: "morePhotos:", forControlEvents: UIControlEvents.TouchUpInside)
        mView.addSubview(label)
        mView.addSubview(moreBtn)
        print("\(section)")
        return mView
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(mTypes.size())
    }
    
    func morePhotos(sender:UIButton){
        let controller = SnapItemPhotoMoreViewController()
        controller.index = sender.tag
        controller.currentItemIndex = sender.tag
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setEditMode(isEdit:Bool){
        isEditMode = isEdit
    }
    
    func deleteRecordPhoto(type:ComFqHalcyonUimodelsOneType?,index:Int32){
        if type == nil {
            return
        }
        
        if index == type!.getCopyByIdWithInt(0).getPhotos().size() {
            return
        }
        
        var id = mTypes.indexOfWithId(type)
        type?.getCopyByIdWithInt(0).getPhotos().removeWithInt(index)
        
        if type?.getPhotoCounter() <= 0 {
            mTypes.removeWithId(type)
            
        }
        tabView.reloadData()
    }
}

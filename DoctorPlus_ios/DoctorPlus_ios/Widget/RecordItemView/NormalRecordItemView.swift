//
//  NormalRecordItemView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol NormalRecordItemViewDelegate{
    
    func getModiftyStatus(isModify:Bool)
}

class NormalRecordItemView: UIView ,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate{

    @IBOutlet weak var allTitleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var templateTableView: UITableView!
    var cellNib:UINib?
    var prototypeCell:UITableViewCell?
    var recordItem:ComFqHalcyonEntityRecordItem?
    var recordItemId = 0
    var isTitleViewShow = false
    var isModify = false
    var titles = [String]()
    var contents = [String]()
    var tmpContents = [String]()
    var templateItems = [String]()
    var longPress:UILongPressGestureRecognizer?
    var delegate:NormalRecordItemViewDelegate?
    var doneView:UIToolbar?
    var doneButton:UIBarButtonItem?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NormalRecordItemView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        allTitleView.hidden = true
        initLongClick()
        self.addSubview(view)
        cellNib  = UINib(nibName: "NormalRecordItemTableViewCell", bundle: nil)
        let templateCellNib = UINib(nibName: "NormalRecordItemTitleTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib!, forCellReuseIdentifier: "NormalRecordItemTableViewCell")
        self.templateTableView.registerNib(templateCellNib, forCellReuseIdentifier: "NormalRecordItemTitleTableViewCell")
        self.prototypeCell = self.tableView.dequeueReusableCellWithIdentifier("NormalRecordItemTableViewCell")
        doneView = UIToolbar(frame: CGRectMake(0, 0, ScreenWidth, 30))
        doneButton = UIBarButtonItem(title: "关闭键盘", style: UIBarButtonItemStyle.Bordered, target: self, action: nil)
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
    }

    
    func tabViewTap(gestrue:UITapGestureRecognizer){
        if !isModify {
            setControllerShow()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NormalRecordItemTableViewCell") as? NormalRecordItemTableViewCell
            cell?.recordItemTitle.text = titles[indexPath.row]
            cell?.recordItemContent.text = tmpContents[indexPath.row]
            cell?.recordItemContent.tag = indexPath.row
            cell?.recordItemContent.delegate = self
            cell?.tableView = tableView
            if isModify {
                cell?.recordItemContent.editable = true
            }else{
                cell?.recordItemContent.editable = false
            }
            return cell!
        }else if tableView.tag == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NormalRecordItemTitleTableViewCell") as? NormalRecordItemTitleTableViewCell
            cell!.titleLabel.text = templateItems[indexPath.row]
            return cell!
        }
        
        return UITableViewCell()
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return titles.count
        }else if tableView.tag == 2 {
            return templateItems.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.tag == 1 {
            if contents.count > 0 {
                let cell = self.prototypeCell as? NormalRecordItemTableViewCell
                cell!.recordItemContent.text = tmpContents[indexPath.row]
                let textViewHeight  = cell!.recordItemContent.sizeThatFits(CGSizeMake(tableView.frame.size.width - 40, CGFloat(FLT_MAX))).height
                return (textViewHeight == 0 ? 25 : textViewHeight) + 45
            }
            return 0
        }else if tableView.tag == 2 {
            return 44
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 2 {
            cellScrollTo(templateItems[indexPath.row])
        }
    }
    
    /**
    view出现和隐藏的动画
    */
    func setControllerShow(){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.4)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        let viewHeight = self.frame.height
        let viewWidth = CGFloat(100)
        if isTitleViewShow {
            isTitleViewShow = false
            allTitleView.frame = CGRectMake(ScreenWidth + viewWidth, 0, viewWidth, viewHeight)
        }else{
            isTitleViewShow = true
            allTitleView.frame = CGRectMake(ScreenWidth - viewWidth, 0, viewWidth, viewHeight)
        }
        UIView.commitAnimations()
    }
    
    override func animationDidStart(anim: CAAnimation) {
        if !isTitleViewShow && allTitleView.hidden {
            allTitleView.hidden = false
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if !isTitleViewShow{
            allTitleView.hidden = true
        }else{
            allTitleView.hidden = false
        }
    }
    
    func setInfo(recordItem: ComFqHalcyonEntityRecordItem!) {
        if recordItem == nil {
            return
        }
        for var i:Int32 = 0 ; i < recordItem.getKeys().size(); i++ {
            titles.append(recordItem.getKeys().getWithInt(i) as! String)
        }
        for var i:Int32 = 0 ; i < recordItem.getContents().size() ; i++ {
            contents.append(recordItem.getContents().getWithInt(i) as! String)
        }
        for var i:Int32 = 0 ; i < recordItem.getTemplates().size() ; i++ {
            let temp = recordItem.getTemplates().getWithInt(i) as! ComFqHalcyonEntityRecordItem_TemplateItem
            templateItems.append(temp.getName())
        }
        tmpContents += contents
        tableView.reloadData()
        templateTableView.reloadData()
    }
    
    func setDatas(recordItem: ComFqHalcyonEntityRecordItem?){
        self.recordItem = recordItem
        setInfo(recordItem)
    }
    
    
    func cellScrollTo(title:String){
        var position = -1
        for (index,item) in titles.enumerate(){
            if item == title{
                position = index
                break
            }
        }
        if position != -1 {
            let scrollIndexPath = NSIndexPath(forRow: position, inSection: 0)
            tableView.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    /**
    初始化长按点击事件
    */
    func initLongClick(){
        
        longPress = UILongPressGestureRecognizer(target: self, action: Selector("cellLongPressed:"))
        longPress?.minimumPressDuration = 1.0
        longPress?.delegate = self
        tableView.addGestureRecognizer(longPress!)
    }
    
    /**
    tableCell的长按点击事件
    */
    func cellLongPressed(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            if recordItem?.getState() == 2 {
                if !isModify {
                    isModify = true
                    delegate?.getModiftyStatus(isModify)
                    tableView.reloadData()
                    if isTitleViewShow {
                        setControllerShow()
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(EDIT_MODEL_KEY, object: isModify)
                }
            }else{
                UIAlertViewTool.getInstance().showAutoDismisDialog("审核中", width: CGFloat(140), height: CGFloat(70))
            }
            
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
       
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        tmpContents[textView.tag] = textView.text
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    
}

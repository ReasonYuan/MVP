//
//  NewNormalRecordView.swift
//  
//
//  Created by Nan on 15/8/13.
//
//

import UIKit
protocol NewNormalRecordViewDelegate : NSObjectProtocol{
    func backToPatientBtnClicked()
    func imageBtnClicked()
}
class NewNormalRecordView: UIView,UITableViewDelegate, UITableViewDataSource{
    
    //MARK:---------------declaer instance variebles
    var uilogic :ComFqHalcyonUilogicRecordDTNormalLogic!
    var recordAbstract: ComFqHalcyonEntityPracticeRecordAbstract!
    var isSlideTableViewShow = false
    weak var delegate: NewNormalRecordViewDelegate?
    //时间标签
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    //提示标签
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var backToPatientBtn: UIButton!
    //病历显示tableView
    @IBOutlet weak var mainTableView: UITableView!
    var isShared:Bool = false
    //滑动tableView
    @IBOutlet weak var slideTableView: UITableView!
    
    //提示标签下方整个视图的view
    @IBOutlet weak var secondView: UIView!
   // var tapGestureRecognizer: UITapGestureRecognizer!
    
    //MARK:---------------the initialization method
    override init(frame: CGRect) {
         super.init(frame: frame)
         let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NewNormalRecordView", owner: self, options: nil)
         let view = nibs.lastObject as! UIView
         view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height )
         self.addSubview(view)
         mainTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
         backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
         backgroundView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0)
         slideTableView.hidden = true
         backgroundView.hidden = true
        
        if isShared {
            
            if isMe{
                isFromSearch = true
               // bigRightBtn.hidden = true
                
            }else{
                backToPatientBtn.hidden = true
                //bigRightBtn.hidden = false
                //bigRightBtn.setTitle("保存", forState : UIControlState.Normal)
                
            }
            
        }else {
            //bigRightBtn.setTitle("编辑", forState : UIControlState.Normal)
            //bigRightBtn.hidden = true
            
        }
        

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 //MARK:---------------methods about the apperance of the SlideTableViewCell
    
    func tabViewTap(sender: UITapGestureRecognizer){
        setControllerShow()
    
         }
    
   
    func setControllerShow(){
        if isSlideTableViewShow {
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.setAnimationDidStopSelector(Selector("hiddenView"))
            isSlideTableViewShow = false
            slideTableView.frame = CGRectMake(ScreenWidth , 0, ScreenWidth*(2/3), ScreenHeight - 60)
            
            backgroundView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0)
            UIView.commitAnimations()
        }else{
            backgroundView.hidden = false
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            isSlideTableViewShow = true
            slideTableView.hidden = false
            slideTableView.frame = CGRectMake(ScreenWidth * (1/3), 0, ScreenWidth*(2/3), ScreenHeight - 60)
            backgroundView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0.85)
            UIView.commitAnimations()
            
        }

        }

    func hiddenView(){
        backgroundView.hidden = true;
    }
    

//MARK:---------------tableView datasource and delegate methods
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == mainTableView{
        var cell = tableView.dequeueReusableCellWithIdentifier("NewRecordCell") as? NewRecordCell
        
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NewRecordCell", owner: self, options: nil)
            cell = nibs.lastObject as? NewRecordCell
            //cell!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap"))
        }
        if uilogic != nil{
        cell!.label.text = uilogic.getInfoTitleByIndexWithInt(Int32(indexPath.row))
            var str = uilogic.getInfoContentByIndexWithInt(Int32(indexPath.row))
        cell!.contentField.text = str
        // cell?.contentField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "textViewTap:"))
           
        }
        return cell!
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SlideTableViewCell") as? SlideTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SlideTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? SlideTableViewCell
            //cell!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap"))
        }
        if uilogic != nil{
            cell!.titleLabel.text = uilogic.getInfoTitleByIndexWithInt(Int32(indexPath.row))
        }
        return cell!
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if uilogic != nil{
        return Int(uilogic.getTemplementsCount())
        }
        return 0
    }
    

    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == mainTableView{
        var cell = tableView.dequeueReusableCellWithIdentifier("NewRecordCell") as? NewRecordCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NewRecordCell", owner: self, options: nil)
            cell = nibs.lastObject as? NewRecordCell
            
        }
        cell!.contentField.text = uilogic.getInfoContentByIndexWithInt(Int32(indexPath.row))
        var textViewHeight  = cell!.contentField.sizeThatFits(CGSizeMake(tableView.frame.size.width - 50, CGFloat(FLT_MAX))).height
        
        return (textViewHeight == 0 ? 10 : textViewHeight + 50)
    }
    
    return 44
}
    //MARK:---------------methods about the anchor point
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == slideTableView {
            
            cellScrollTo(uilogic.getInfoTitleByIndexWithInt(Int32(indexPath.row)))
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
    
    func cellScrollTo(title:String){
        var position = -1
        var number = Int32(uilogic.getTemplementsCount())
        for(var i = Int32(0);i<number;i++){
            if title == uilogic.getInfoTitleByIndexWithInt(i){
              position = Int(i)
                break
            }

        }
        if position != -1 {
            var scrollIndexPath = NSIndexPath(forRow: position, inSection: 0)
            mainTableView.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition:UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    //MARK:---------------methods about clicking the buttons
    
    @IBAction func imageBtnClicked(sender: UIButton) {
       delegate?.imageBtnClicked()
        
    }

    @IBAction func patientBtnClicked(sender: UIButton) {
        
        delegate?.backToPatientBtnClicked()
    }
    
    //MARK:---------------update the status of the top remind Label
    func updateTopLabel(){
        remindLabel.text = uilogic.getNoticeMessage()
        if (remindLabel.text == nil || remindLabel.text == ""){//转变到编辑中状态
            remindLabel.hidden = true
            
           
            secondView.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight - 70)
            
            
        }else{
            remindLabel.hidden = false
             secondView.frame = CGRectMake(0,30,ScreenWidth,ScreenHeight - 100)
            var str = remindLabel.text!
            var length = str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            
            if ( length > 80){
                labelTextAnimationStart()
            }
        }
    
    }
    func labelTextAnimationStart(){
    
        remindLabel.frame = CGRectMake(0, 0, remindLabel.frame.size.width + ScreenWidth/8, remindLabel.frame.height)
        remindLabel.textAlignment =  NSTextAlignment.Center
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(5.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationRepeatCount(100)
        UIView.setAnimationRepeatAutoreverses(true)
        remindLabel.frame = CGRectMake(-(ScreenWidth/10) , 0, remindLabel.frame.size.width, remindLabel.frame.size.height)
        UIView.commitAnimations()

    }

}
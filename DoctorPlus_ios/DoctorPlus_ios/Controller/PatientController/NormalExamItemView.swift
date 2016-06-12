//
//  NormalExamItemView.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
protocol NormalExamItemViewDelegate : NSObjectProtocol{
    func onImgClick()
    func onBackClick()
    func onBackToAttachmentClick()
}
class NormalExamItemView: UIView,ChartViewDataSource,ChartViewDelegate ,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2GetPatientItemExamLogic_GetPatientItemExamCallBack,ComFqHalcyonLogic2EditOneExamItemLogic_EditOneExamItemCallBack,ComFqHalcyonLogic2GetRecordInfoByItemLogic_GetRecordInfoByItemCallBack{
    var directions: ChartViewRefreshDirection!
    var mItemExamList: JavaUtilArrayList! = JavaUtilArrayList()
    var selectItem = 0
    var itemExam:ComFqHalcyonEntityRecordItem_RecordExamItem!
    var status:ComFqHalcyonEntityRecordItem_EXAM_STATEEnum!
    var selectedItemName:String!
    var recordDTExamLogic:ComFqHalcyonUilogicRecordDTExamLogic!
    
    var getPatientItemExamLogic: ComFqHalcyonLogic2GetPatientItemExamLogic?
    var editLogic :ComFqHalcyonLogic2EditOneExamItemLogic?
    
    var getRecordByItemLogic:ComFqHalcyonLogic2GetRecordInfoByItemLogic?
    var examList: JavaUtilArrayList! = JavaUtilArrayList()
    var recordAbstract:ComFqHalcyonEntityPracticeRecordAbstract!
    var recordItem: ComFqHalcyonEntityRecordItem!
    var xmName:String = ""
    var value:String = ""
    var unit:String = ""
    var pageIndex:Int32 = 1
    var isFirstShow:Bool = true
    var showIndexInData:Int32 = -1
    
    var isScroll:Bool = false
    var attachmentListener:AttachmentListener = AttachmentListener()
    var item:ComFqHalcyonEntityRecordItem_RecordExamItem!
    var indexs:Int32 = 0
    weak var delegate:NormalExamItemViewDelegate?
    
    @IBOutlet weak var backToPatientBtn: UIButton!
    @IBOutlet weak var lookImage: UIButton!
    @IBOutlet weak var contentTableview: UITableView!
    @IBOutlet weak var ChartViewContainer: ChartView!
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordName: UILabel!
    @IBOutlet weak var sampleLabel: UILabel!
    
    @IBOutlet weak var chartTimeLabel: UILabel!
    
    @IBOutlet weak var backToAttachmentBtn: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NormalExamItemView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        view.backgroundColor = UIColor(red: CGFloat(241.0/255.0), green: CGFloat(241.0/255.0), blue: CGFloat(241.0/255.0), alpha: CGFloat(1))
        self.addSubview(view)
        ChartViewContainer.chartDataSource = self
        ChartViewContainer.chartDelegate = self
        ChartViewContainer.isShowUnit = false
        ChartViewContainer.strokeColor = UIColor(red: 0/255.0, green: 151/255.0, blue: 214/255.0, alpha: 1)
        ChartViewContainer.textColor = UIColor.grayColor()
        ChartViewContainer.lineColor = UIColor.grayColor()
        //        noItemLabel.textColor = UIColor.redColor()
        getPatientItemExamLogic = ComFqHalcyonLogic2GetPatientItemExamLogic(comFqHalcyonLogic2GetPatientItemExamLogic_GetPatientItemExamCallBack: self)
        editLogic = ComFqHalcyonLogic2EditOneExamItemLogic(comFqHalcyonLogic2EditOneExamItemLogic_EditOneExamItemCallBack: self)
        getRecordByItemLogic = ComFqHalcyonLogic2GetRecordInfoByItemLogic(comFqHalcyonLogic2GetRecordInfoByItemLogic_GetRecordInfoByItemCallBack: self)
        //        labelTextAnimationStart()
        backToAttachmentBtn.setImage(UIImage(named: "icon_attachment.png"), forState: UIControlState.Normal)
        backToAttachmentBtn.setImage(UIImage(named: "icon_attachment_highlight.png"), forState: UIControlState.Highlighted)
        lookImage.setImage(UIImage(named: "icon_on.png"), forState: UIControlState.Normal)
        lookImage.setImage(UIImage(named: "icon_on_highlight.png"), forState: UIControlState.Highlighted)
        backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Normal)
        backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Highlighted)
        if ExamItemViewController().isFromChart! {
            backToPatientBtn.hidden = true
        }
        

    }
    
    func startGetPatientItemExamLogic(page:Int32){
        if(recordAbstract != nil && recordDTExamLogic != nil){
            let recordInfoId = recordAbstract.getRecordInfoId()
            let recordItemid = recordAbstract.getRecordItemId()
            let examName = recordDTExamLogic.getExamByIndexWithInt(0).getName()
            let examUnit = recordDTExamLogic.getExamByIndexWithInt(0).getUnit()
            recordName.text = recordAbstract.getRecordItemName()
            recordTimeLabel.text = recordAbstract.getDeal2Time()
            getPatientItemExamLogic?.GetPatientItemExamWithInt(recordInfoId, withInt: recordItemid, withNSString: examName, withNSString: examUnit, withInt: page,withInt: (Int32)(ChartViewContainer.cellCountOnePage()))
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func backToAttachment(sender: AnyObject) {
        delegate?.onBackToAttachmentClick()
    }
    @IBAction func backBtnClicked(sender: AnyObject) {
        delegate?.onBackClick()
    }
    @IBAction func lookImageClicked(sender: AnyObject) {
        //        showImages()
        //        imagesView.hidden = false
        delegate?.onImgClick()
    }
    
    func chartView(view: ChartView!, didClickedAtIndex index: Int) {
        if(mItemExamList != nil){
            if mItemExamList.size() > Int32(index) {
                //                year.text = (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getYear()
                //                month.text = (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getMonth()
                chartTimeLabel.text = "20" + (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getYear() + "年" + (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getMonth() + "月" + (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getDay() + "日"
                isFirstShow = false
                
                selectedItemName = (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getItemName()
                //通过examID获取化验项列表
                getRecordByItemLogic?.loadRecordItemWithInt((mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getExamId())
            }
        }
    }
    
    func chartView(view: ChartView!, changeCicleColor index: Int) -> Bool {
        if(mItemExamList != nil){
            if mItemExamList.size() > Int32(index) {
                
                let itemExam = mItemExamList.getWithInt(Int32(index)) as? ComFqHalcyonEntityItemExam
                
                if itemExam != nil {
                    return  itemExam!.getState() == ComFqHalcyonEntityRecordItem_EXAM_STATEEnum.values().objectAtIndex(UInt(ComFqHalcyonEntityRecordItem_EXAM_STATE_M.rawValue)) as? ComFqHalcyonEntityRecordItem_EXAM_STATEEnum ? false : true
                }else{
                    return false
                }
            }
            return false
        }
        return false
    }
    
    
    func chartViewCicleColor(view: ChartView!) -> UIColor! {
        return UIColor.redColor()
    }
    
    func chartView(view: ChartView!, firstCellShowIndex index: Int) {
        
    }
    
    func numberOfCellInChartView(chartView: ChartView!) -> Int {
        return (ChartViewContainer.cellCountOnePage())
    }
    
    func chartView(view: ChartView!, dataForIndex index: Int) -> CGFloat {
        if(mItemExamList != nil){
            if mItemExamList.size() > Int32(index) {
                
                let itemExam = mItemExamList.getWithInt(Int32(index)) as? ComFqHalcyonEntityItemExam
                
                if itemExam != nil {
                    return  CGFloat((itemExam!.getExamValue() as NSString).floatValue)
                }else{
                    return 0
                }
            }
            return 0
        }
        return 0
    }
    
    func chartView(view: ChartView!, toastText index: Int) -> String! {
        if(mItemExamList != nil){
            if mItemExamList.size() > Int32(index) {
                
                let itemExam = mItemExamList.getWithInt(Int32(index)) as? ComFqHalcyonEntityItemExam
                
                if itemExam != nil {
                    return itemExam!.getExamValue() as NSString as String
                }else{
                    return "无"
                }
            }
            return "无"
        }
        return "无"
    }
    
    func chartView(view: ChartView!, titleForCell index: Int) -> String! {
        if(mItemExamList != nil){
            if mItemExamList.size() > Int32(index) {
                return (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getYear() + "/" + (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getMonth() + "/" + (mItemExamList!.getWithInt(Int32(index)) as! ComFqHalcyonEntityItemExam).getDay()
            }
        }
        return ""
    }
    
    func chartView(view: ChartView!, canRefresh direction: ChartViewRefreshDirection) -> Bool {
        return true
    }
    
    func chartView(view: ChartView!, onRefresh direction: ChartViewRefreshDirection) {
        directions = direction
        
        isScroll = true
        if isFirstShow {
            if(directions == ChartViewRefreshDirection.DirectionLeft){
                if pageIndex > 1 {
                    pageIndex--
                    startGetPatientItemExamLogic(pageIndex)
                }
            }else{
                
                if mItemExamList.size() == (Int32)(ChartViewContainer.cellCountOnePage()) {
                    pageIndex++
                    startGetPatientItemExamLogic(pageIndex)
                }
            }
        }else{
            item = self.recordItem?.getExams().getWithInt(indexs) as! ComFqHalcyonEntityRecordItem_RecordExamItem
            if(directions == ChartViewRefreshDirection.DirectionLeft){
                
                if pageIndex > 1 {
                    pageIndex--
                    if recordItem != nil && item != nil {
                        getPatientItemExamLogic?.GetPatientItemExamWithInt(self.recordItem.getRecordInfoId(), withInt: self.recordItem.getRecordItemId() , withNSString: item.getName(), withNSString: item.getUnit(), withInt: pageIndex,withInt: (Int32)(ChartViewContainer.cellCountOnePage()))
                    }
                }
            }else{
                if mItemExamList.size() == (Int32)(ChartViewContainer.cellCountOnePage()) {
                    if recordItem != nil && item != nil{
                        pageIndex++
                        getPatientItemExamLogic?.GetPatientItemExamWithInt(self.recordItem.getRecordInfoId(), withInt: self.recordItem.getRecordItemId() , withNSString: item.getName(), withNSString: item.getUnit(), withInt: pageIndex,withInt: (Int32)(ChartViewContainer.cellCountOnePage()))
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        let label1 = UILabel(frame: CGRectMake(0, 0, 1, cell.frame.height))
        let label2 = UILabel(frame: CGRectMake(0, 0, ScreenWidth - 20, 1))
        let label3 = UILabel(frame: CGRectMake(0, 40, ScreenWidth - 20, 1))
        let label4 = UILabel(frame: CGRectMake((ScreenWidth - 20)/5*3, 0, 1, cell.frame.height - 4))
        let label5 = UILabel(frame: CGRectMake((ScreenWidth - 20)/5*4 , 0, 1, cell.frame.height - 4))
        let label6 = UILabel(frame: CGRectMake((ScreenWidth - 20) - 1, 0, 1, cell.frame.height))
        
        
        let XmLabel = UILabel(frame: CGRectMake(0, 0, (ScreenWidth - 20)/5*3, cell.frame.height - 4))
        let ResultLabel = UILabel(frame: CGRectMake((ScreenWidth - 20)/5*3, 0, (ScreenWidth - 20)/5, cell.frame.height - 4))
        let UnitLabel = UILabel(frame: CGRectMake((ScreenWidth - 20)/5*4, 0, (ScreenWidth - 20)/5, cell.frame.height - 4))
        XmLabel.textColor = UIColor.darkGrayColor()
        XmLabel.font = UIFont.systemFontOfSize(10.0)
        XmLabel.textAlignment = NSTextAlignment.Center
        XmLabel.numberOfLines = 2
        XmLabel.tag = indexPath.row
        if(selectItem == indexPath.row){
            XmLabel.backgroundColor = UITools.colorWithHexString("#0080c1") //Color.color_violet
            XmLabel.textColor = UIColor.whiteColor()
        }
        ResultLabel.textColor = UIColor.darkGrayColor()
        ResultLabel.font = UIFont.systemFontOfSize(10.0)
        ResultLabel.textAlignment = NSTextAlignment.Center
        ResultLabel.numberOfLines = 1
        
        
        UnitLabel.textColor = UIColor.darkGrayColor()
        UnitLabel.font = UIFont.systemFontOfSize(10.0)
        UnitLabel.textAlignment = NSTextAlignment.Center
        UnitLabel.numberOfLines = 2
        if isFirstShow {
            if(recordDTExamLogic != nil){
                if recordDTExamLogic.getNoticeMessage() != "" {
                    //                    remindLabel.text = recordDTExamLogic.getNoticeMessage()
                    //                    remindLabel.hidden = false
                    //                    titleView.hidden = false
                }else{
                    //                    remindLabel.text = recordDTExamLogic.getNoticeMessage()
                    //                    remindLabel.hidden = true
                    //                    titleView.hidden = true
                }
                ResultLabel.text = recordDTExamLogic.getExamValueByIndexWithInt(Int32(indexPath.row))
                XmLabel.text = recordDTExamLogic.getExamNameByIndexWithInt(Int32(indexPath.row))
                UnitLabel.text = recordDTExamLogic.getExamUnitByIndexWithInt(Int32(indexPath.row))
                status = recordDTExamLogic.getExamStateByIndexWithInt(Int32(indexPath.row))
            }
        }else{
            let item = examList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityRecordItem_RecordExamItem
            ResultLabel.text = item.getExamValus()
            XmLabel.text = item.getName()
            UnitLabel.text = item.getUnit()
            status = item.getState()
        }
        
        if (status != ComFqHalcyonEntityRecordItem_EXAM_STATEEnum.values().objectAtIndex(UInt(ComFqHalcyonEntityRecordItem_EXAM_STATE_M.rawValue)) as? ComFqHalcyonEntityRecordItem_EXAM_STATEEnum) {
            UnitLabel.textColor = UITools.colorWithHexString("#e61c1a")
            ResultLabel.textColor = UITools.colorWithHexString("#e61c1a")
            XmLabel.textColor = UITools.colorWithHexString("#e61c1a")
        }
        
        label1.backgroundColor = UIColor.lightGrayColor()
        label2.backgroundColor = UIColor.lightGrayColor()
        label3.backgroundColor = UIColor.lightGrayColor()
        label4.backgroundColor = UIColor.lightGrayColor()
        label5.backgroundColor = UIColor.lightGrayColor()
        label6.backgroundColor = UIColor.lightGrayColor()
        cell.contentView.frame = CGRectMake(0, 0, ScreenWidth, 44)
        cell.contentView.addSubview(label1)
        cell.contentView.addSubview(label2)
        cell.contentView.addSubview(label3)
        cell.contentView.addSubview(label4)
        cell.contentView.addSubview(label5)
        cell.contentView.addSubview(label6)
        cell.contentView.addSubview(XmLabel)
        cell.contentView.addSubview(ResultLabel)
        cell.contentView.addSubview(UnitLabel)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFirstShow {
            if(recordDTExamLogic != nil){
                return Int(recordDTExamLogic.getExamCount())
            }
        }else {
            if recordItem != nil {
                return Int(recordItem.getExams().size())
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, ScreenWidth - 20, 30))
        view.backgroundColor = UITools.colorWithHexString("#dfdfdf") //UIColor(red: 193/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1.0)
        let label1 = UILabel(frame: CGRectMake(0, 0, view.frame.width/5*3, view.frame.height))
        label1.textAlignment = NSTextAlignment.Center
        label1.text = "项目"
        label1.font = UIFont.systemFontOfSize(12.0)
        label1.textColor = UIColor.darkGrayColor()
        let label2 = UILabel(frame: CGRectMake(view.frame.width/5*3, 0, view.frame.width/5, view.frame.height))
        label2.textAlignment = NSTextAlignment.Center
        label2.text = "结果"
        label2.font = UIFont.systemFontOfSize(12.0)
        label2.textColor = UIColor.darkGrayColor()
        let label3 = UILabel(frame: CGRectMake(view.frame.width/5*4, 0, view.frame.width/5, view.frame.height))
        label3.textAlignment = NSTextAlignment.Center
        label3.text = "单位"
        label3.font = UIFont.systemFontOfSize(12.0)
        label3.textColor = UIColor.darkGrayColor()
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        _ = tableView.cellForRowAtIndexPath(indexPath)
        
        isScroll = false
        if(isFirstShow){
            xmName = recordDTExamLogic.getExamNameByIndexWithInt(Int32(indexPath.row))
            value = recordDTExamLogic.getExamValueByIndexWithInt(Int32(indexPath.row))
            unit = recordDTExamLogic.getExamUnitByIndexWithInt(Int32(indexPath.row))
            if(recordAbstract != nil && recordDTExamLogic != nil){
                getPatientItemExamLogic?.GetPatientItemExamWithInt(recordAbstract.getRecordInfoId(), withInt: recordAbstract.getRecordItemId(), withNSString: xmName, withNSString: unit, withInt: 1,withInt: (Int32)(ChartViewContainer.cellCountOnePage()))
            }
            if(indexPath.row != selectItem){
                pageIndex == 1
            }
        }else{
            
            item = self.recordItem?.getExams().getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityRecordItem_RecordExamItem
            value = item.getExamValus()
            xmName = item.getName()
            unit = item.getUnit()
            if recordItem != nil {
                getPatientItemExamLogic?.GetPatientItemExamWithInt(self.recordItem.getRecordInfoId(), withInt: self.recordItem.getRecordItemId() , withNSString: item.getName(), withNSString: item.getUnit(), withInt: 1,withInt: (Int32)(ChartViewContainer.cellCountOnePage()))
            }
            if(indexPath.row != selectItem){
                pageIndex == 1
            }
        }
        selectItem = indexPath.row
        tableView.reloadData()
    }
    
    //获取化验项失败的回调
    func GetPatientItemExamErrorWithInt(code: Int32, withNSString msg: String!) {
//        self.makeToast(msg)
        FQToast.makeError().show(msg, superview: Tools.getCurrentViewController().view)
    }
    
    //获取化验项成功的回调
    func GetPatientItemExamResultWithJavaUtilArrayList(itemExamList: JavaUtilArrayList!) {
        
        if itemExamList.size() > 0 {
            //            noItemLabel.text = ""
            mItemExamList.clear()
            recordName.text = recordAbstract.getRecordItemName()
            recordTimeLabel.text = recordAbstract.getDeal2Time()
            mItemExamList = itemExamList
            sampleLabel.text = "标本:" + itemExamList.getWithInt(0).getSample()
            chartTimeLabel.text = "20" + (mItemExamList!.getWithInt(0) as! ComFqHalcyonEntityItemExam).getYear() + "年" + (mItemExamList!.getWithInt(0) as! ComFqHalcyonEntityItemExam).getMonth() + "月" + (mItemExamList!.getWithInt(0) as! ComFqHalcyonEntityItemExam).getDay() + "日"
        }else{
            if !isScroll {
                mItemExamList.clear()
                chartTimeLabel.text = ""
                //                noItemLabel.text = "化验结果数值过少，无法展现图表"
            }else{
                pageIndex--
                //                return
            }
        }
        recordName.text = recordAbstract.getRecordItemName()
        recordTimeLabel.text = recordAbstract.getDeal2Time()
        ChartViewContainer.reloadData()
    }
    
    func labelTextAnimationStart(){
        //        var message = remindLabel.text
        
        //        remindLabel.frame = CGRectMake(0, remindLabel.frame.origin.y, remindLabel.frame.size.width + ScreenWidth/5, remindLabel.frame.height)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(5.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationRepeatCount(100)
        UIView.setAnimationRepeatAutoreverses(true)
        //        remindLabel.frame = CGRectMake(-(ScreenWidth/10) , remindLabel.frame.origin.y, remindLabel.frame.size.width, remindLabel.frame.size.height)
        UIView.commitAnimations()
    }
    
    
    
    
    
    //修改后点击确认按钮 修改该化验项
    func editConfirm(){
        editLogic?.EditOneExamItemWithInt(recordDTExamLogic.getExamByIndexWithInt(Int32(selectItem)).getExamId(), withNSString: xmName, withNSString: value, withNSString: unit)
    }
    
    //修改成功回调
    func EditOneExamItemResultWithNSString(msg: String!) {
        //        UIAlertViewTool.getInstance().showAutoDismisDialog(msg)
//        self.makeToast(msg)
        FQToast.makeSystem().show(msg, superview: Tools.getCurrentViewController().view)
        recordDTExamLogic.resquestRecordDetailDataWithInt(recordAbstract.getRecordInfoId())
    }
    //修改失败回调
    func EditOneExamItemErrorWithInt(code: Int32, withNSString msg: String!) {
        //        UIAlertViewTool.getInstance().showAutoDismisDialog(msg)
//        self.makeToast(msg)
        FQToast.makeError().show(msg, superview: Tools.getCurrentViewController().view)
    }
    
    //第一次通过itemID获取病历详情的回调
    func doRecordItemBackWithComFqHalcyonEntityRecordItem(recordItem: ComFqHalcyonEntityRecordItem!) {
        if recordItem != nil {
            examList.clear()
            self.recordItem = recordItem
            for (var i:Int32 = 0 ; i < recordItem.getExams().size() ;i++){
                if((recordItem.getExams().getWithInt(i) as! ComFqHalcyonEntityRecordItem_RecordExamItem).getName() == selectedItemName){
                    examList.addWithInt(0, withId: recordItem.getExams().getWithInt(i))
                    indexs = i
                }else{
                    examList.addWithId(recordItem.getExams().getWithInt(i))
                }
            }
            recordName.text = recordAbstract.getRecordItemName()
            recordTimeLabel.text = recordAbstract.getDeal2Time()
            sampleLabel.text = "标本:" + examList.getWithInt(0).getSample()
            selectItem = 0
            contentTableview.reloadData()
        }
        NSNotificationCenter.defaultCenter().postNotificationName("OnExamItemChanged", object: recordItem.getImageIds())
    }
}

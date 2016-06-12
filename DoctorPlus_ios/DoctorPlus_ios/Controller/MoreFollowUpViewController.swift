//
//  MoreFollowUpViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MoreFollowUpViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback{

    @IBOutlet weak var tableview: UITableView!
    var Dates:Int64?
    var OneDayDaas = JavaUtilArrayList()
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        let mCurrentDate = ComFqLibToolsTimeFormatUtils.getCNDate2WithLong(Dates!)
        setTittle("\(mCurrentDate)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "MoreFollowUpViewController"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getOneDayHomeData(Dates!)
    }
    
    func getOneDayHomeData(time:Int64){
        ComFqHalcyonLogic2DoctorHomeLogic().requestOneDayPatientsWithLong(time, withComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback: self)
    }
    
    
    //回调
    func feedHomeDatasWithJavaUtilArrayList(infos: JavaUtilArrayList!) {
        OneDayDaas.clear()
        OneDayDaas = infos
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    func feedMonthWithJavaUtilMap(data: JavaUtilMap!) {
        
    }
    
    func errorMonthWithNSString(msg: String!) {
        
    }
    
    func errorWithNSString(msg: String!) {
        
    }
    
    func tableView(tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
            return Int(OneDayDaas.getWithInt(0).getDatas().size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MoreFollowUpTableViewCell") as? MoreFollowUpTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("MoreFollowUpTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? MoreFollowUpTableViewCell
        }
        UITools.setRoundBounds(17.0, view: cell!.headImage)
        UITools.setBorderWithView(1.0, tmpColor: Color.color_emerald.CGColor, view:  cell!.headImage)
        let mData: AnyObject! = OneDayDaas.getWithInt(0)
        let mHomeData = mData.getDataWithInt(Int32(indexPath.row))
        cell?.nameLabel.text = mHomeData.getmPatientName()
        cell?.followUpTitle.text = "随访标题:  \(mHomeData.getmFollowUpName())"
        let photo = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(mHomeData.getmImgID())
        cell?.headImage.downLoadImageWidthImageId(photo.getImageId(), callback: { (view, path) -> Void in
            let tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
        return cell!
    }
    
    //随访列表点击事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let mData: AnyObject! = OneDayDaas.getWithInt(0)
        let mHomeData = mData.getDataWithInt(Int32(indexPath.row))
        //跳转到查看随访界面
        let controller = LookFollowUpViewController()
        controller.mTimerId = mHomeData.getmFollowUpId()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//
//  SavedSearchResultsView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class SavedSearchResultsView: UIView ,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogicPracticeSearchCriteriaLogic_GetSearchCriteriaInterface,ComFqHalcyonLogicPracticeSearchCriteriaLogic_DeleteSearchCriteriaInterface{
    
    @IBOutlet weak var resultTableView: UITableView!
    
    var results = [ComFqHalcyonEntityPracticeSearchParams]()
    var deleteIndexPath:NSIndexPath?
    var loadingDailog:CustomIOS7AlertView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initXib()
        loadData()
        
    }
    
    func loadData(){
        let logic = ComFqHalcyonLogicPracticeSearchCriteriaLogic()
        logic.GetSearchConditionWithInt(1, withInt: 400, withComFqHalcyonLogicPracticeSearchCriteriaLogic_GetSearchCriteriaInterface: self)
    }
    
    func onGetErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    func onGetSuccessWithJavaUtilArrayList(searchParamss: JavaUtilArrayList!) {
        results.removeAll()
        for var i:Int32 = 0 ; i < searchParamss.size() ; i++ {
            let params = searchParamss.getWithInt(i) as! ComFqHalcyonEntityPracticeSearchParams
            results.append(params)
        }
        
        resultTableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化要显示的xib
    func initXib() {
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SavedSearchResultsView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        let line = DashedLineView(frame: CGRect(x: 16, y: 48, width: ScreenWidth - 32, height: 1))
        view.addSubview(line)
        self.addSubview(view)
        
        resultTableView.registerNib(UINib(nibName: "SavedSearchResultTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SavedSearchResultTableViewCell")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = resultTableView.dequeueReusableCellWithIdentifier("SavedSearchResultTableViewCell") as! SavedSearchResultTableViewCell
        cell.setData(results[indexPath.row].getName())
        cell.visualBtn.tag = indexPath.row
        cell.visualBtn.addTarget(self, action: "visualClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    /**
     可视化点击
     */
    func visualClick(sender:UIButton){
        print(sender.tag)
        /// TOOD 未处理
        let searchParams = results[sender.tag]
        let controller = Tools.getCurrentViewController().navigationController?.viewControllers[0] as! MainViewController
        controller.selectedIndex = 0
        (controller.viewControllers![0] as! ChartHomeViewController).reloadFilterData(searchParams.getPatientIds())
        Tools.getCurrentViewController().navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let searchParams = results[indexPath.row]
        let controller = SearchPatientController()
        controller.params = searchParams
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        loadingDailog = UIAlertViewTool.getInstance().showLoadingDialog("删除中...")
        deleteIndexPath = indexPath
        
        let logic = ComFqHalcyonLogicPracticeSearchCriteriaLogic()
        
        let list  = JavaUtilArrayList()
        
        list.addWithId(JavaLangInteger(int: results[indexPath.row].getId()))
        logic.DeleteSearchConditionWithJavaUtilArrayList(list, withComFqHalcyonLogicPracticeSearchCriteriaLogic_DeleteSearchCriteriaInterface: self)
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func onDeleteSuccess() {
        loadingDailog!.close()
        results.removeAtIndex(deleteIndexPath!.row)
        resultTableView.deleteRowsAtIndexPaths([deleteIndexPath!], withRowAnimation: UITableViewRowAnimation.Top)
        FQToast.makeSystem().show("删除成功", superview: Tools.getCurrentViewController().view)
    }
    
    func onDeleteErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDailog!.close()
        FQToast.makeError().show(msg, superview: Tools.getCurrentViewController().view)
    }
}

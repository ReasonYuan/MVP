//
//  BrowRecordItemViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordItemViewController: UIViewController,YRADScrollViewDataSource,YRADScrollViewDelegate{

    var scrollView: YRADScrollView!
    /**是不是查看分享模式*/
    var isShareModel:Bool = false
    var clickPosition:Int32 = 0
    var itemList = JavaUtilArrayList()
    var dialog:CustomIOS7AlertView?
    var patientId:Int32 = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = YRADScrollView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.cycleEnabled = false
        self.view.addSubview(scrollView)
        scrollView.scrollViewToIndex(clickPosition)
//        dialog = UIAlertViewTool.getInstance().showLoadingDialog("正在加载数据...")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func viewForYRADScrollView(adScrollView: YRADScrollView!, atPage pageIndex: Int) -> UIView! {
        var  cell:BrowRecordItemDetailView!
        let cacheView: AnyObject! = adScrollView.dequeueReusableView()
        if (cacheView != nil){
            cell = cacheView as! BrowRecordItemDetailView
        }
        if( cell == nil ) {
            cell =  BrowRecordItemDetailView(frame:adScrollView.frame)
            cell.tag = -2
        }
        cell.navigation = self.navigationController
        cell.isShareModel = isShareModel
        cell.itemList = itemList
        cell.tmpScrollView  = scrollView
    
        if( cell.tag != pageIndex){
            cell.clearImage()
            cell.centerView.subviews.map{$0.removeFromSuperview()}
            cell.initData(self.itemList.getWithInt(Int32(pageIndex)) as! ComFqHalcyonEntityRecordItemSamp, callBack: { (item) -> () in
                
                self.dialog?.close()
                /**BrowRecordItemDetailView的centerView**/
                var mRecordItem:ComFqHalcyonEntityRecordItem?
                mRecordItem = item
                let recordType = mRecordItem?.getRecordType()
                if recordType == ComFqLibRecordRecordConstants_TYPE_EXAMINATION {
                    //化验
                    if mRecordItem?.getExams() != nil && mRecordItem?.getExams().size() != 0 {
                        //标准化验单
                        let frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 109 - 70)
                        let view = NormalExamUIView(frame: frame)
                        view.patientId = self.patientId
                        view.navigationController = self.navigationController
                        view.setDatas(mRecordItem)
                        cell.centerView.addSubview(view)
                    }else{
                        //非标准化验单
                        let frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 109 - 70)
                        let view = UnnormalExamUIView(frame: frame)
//                        view.setDatas(mRecordItem)
                        cell.centerView.addSubview(view)
                    }
                    
                }else if recordType == ComFqLibRecordRecordConstants_TYPE_MEDICAL_IMAGING{
                    //检查
                    let frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 109 - 70)
                    let view = ImgRecordUIView(frame: frame)
                    view.setDatas(mRecordItem)
                    cell.centerView.addSubview(view)
                }else{
                    let frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 109 - 70)
                    let view = NormalRecordItemView(frame: frame)
                    view.delegate = cell.self
                    view.setDatas(mRecordItem)
                    cell.centerView.addSubview(view)
                }
            })
        }else{
             self.dialog?.close()
        }
        cell.tag = pageIndex
        return cell
    }
    
    func numberOfViewsForYRADScrollView(adScrollView: YRADScrollView!) -> UInt {
        return UInt(itemList.size())
    }
    
    
    func adScrollView(adScrollView: YRADScrollView!, didScrollToPage pageIndex: Int) {
        print("当前的page是:\(pageIndex)")
    }
}

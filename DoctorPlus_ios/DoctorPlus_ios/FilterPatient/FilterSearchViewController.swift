//
//  FilterSearchViewController.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class FilterSearchViewController: BaseViewController ,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack{

    
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    var params:ComFqHalcyonEntityPracticeSearchParams?
    var searchKey = ""
    var isFromChart = false
    var isFromHome = false
    var filterKeysView:ChoseFilterKeysView!
    var searchResultsView:SavedSearchResultsView!
    
    var isKeysViewShow = true
    var isAnimationFinished = true
    
    var filters = JavaUtilArrayList()
    
    var patientId:Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWidgets()
    }
    
    override func getXibName() -> String {
        return "FilterSearchViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initLogic(){
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        setParams(1, searchKey: searchKey, searchFilter: filters, isFilter: true)
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
    }
    
    func setFilterParamPatientId(patientId:Int32 = 0) {
        self.isFromHome = true
        self.patientId = patientId
    }
    
    func setParams(page:Int32,searchKey:String,searchFilter:JavaUtilArrayList?,isFilter:Bool){
        self.params = ComFqHalcyonEntityPracticeSearchParams()
        params!.setResponseTypeWithInt(0)
        params!.setKeyWithNSString(searchKey)
        params!.setPageWithInt(page)
        params!.setPageSizeWithInt(10)
        params?.setNeedFiltersWithBoolean(isFilter)
        if patientId != 0 {
            params?.setPagintIdWithInt(patientId)
        }
    }
    
    func initWidgets() {
        setTittle("筛选")
        hiddenRightImage(true)
        
        let frame = CGRect(x: 0, y: 60, width: ScreenWidth, height: ScreenHeight - 130)
        filterKeysView = ChoseFilterKeysView(frame: frame)
        searchResultsView = SavedSearchResultsView(frame: frame)
        self.containerView.addSubview(searchResultsView)
        filterKeysView.isFromChart = isFromChart
        self.containerView.addSubview(filterKeysView)
        if isFromHome {
            initLogic()
        }else{
            filterKeysView.setFilterKeys(filters)
        }
    }
    
    @IBAction func onCtrlFilterKeysViewListener(sender: UIButton) {
        
        if !isAnimationFinished {
            return
        }
        self.isAnimationFinished = false
        if isKeysViewShow {
            sender.setTitle("更多筛选条件", forState: UIControlState.Normal)
        } else {
            sender.setTitle("收起", forState: UIControlState.Normal)
        }
        
        isKeysViewShow = !isKeysViewShow
        showOrHiddenKeysView(isKeysViewShow)
    }

    func showOrHiddenKeysView(isShow:Bool) {
        if isShow {
            self.filterKeysView.hidden = false
            UIView.animateWithDuration(1.2, animations: { () -> Void in
                    self.filterKeysView.transform = CGAffineTransformTranslate(self.filterKeysView.transform, CGFloat(self.filterKeysView.frame.size.width), CGFloat(0))
                }, completion: { (isFinish) -> Void in
                        self.isAnimationFinished = isFinish
            })
        }else{
            UIView.animateWithDuration(1.2, animations: { () -> Void in
                self.filterKeysView.transform = CGAffineTransformTranslate(self.filterKeysView.transform, CGFloat(-self.filterKeysView.frame.size.width), CGFloat(0))
                }, completion: { (isFinish) -> Void in
                    self.isAnimationFinished = isFinish
                    self.filterKeysView.hidden = true
            })
        }
    }
    
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        self.filters = filters
        filterKeysView.setFilterKeys(filters)
    }
    
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
}

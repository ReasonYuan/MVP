//
//  ExplorationViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate{

    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet var historyKeyTable: UITableView! //搜索历史关键字
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var ctrlView: UIView!
    
    @IBOutlet var waitRecCtrlView: UIView!
    @IBOutlet var trashCtrlView: UIView!
    
    var isCtrlViewShow = false
    
    var explorationView:ExplorationView! //我的病例库
    var myPatientView:ExplorationRecView! //我的患者
    var recOverView:ExplorationRecView! //云识别
    var trashView:ExplorationRecView! //回收站
    
    var pageViews = [UIView]()
    
    var explorationViewY:CGFloat!
    
    var contentFrame:CGRect!
    var contentShowCtrlFrame:CGRect!
    var scrollFrame:CGRect!
    var scrollShowCtrlFrame:CGRect!
    var verLineShowFrame:CGRect!
    var verLineHiddenFrame:CGRect!
    var ctrlViewShowFrame:CGRect!
    var ctrlViewHiddenFrame:CGRect!
    var historyKeyFrame:CGRect!
    
    var scrollContentSize:CGSize!
    var showCtrlContentSize:CGSize!
    
    var showViewPosition = 0
    
    var isExperience = false //判断是否是体验账号
    
    @IBOutlet weak var btnMyRecord: UIButton!
    @IBOutlet weak var btnMyPatient: UIButton!
    @IBOutlet weak var btnRecOver: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var labMyRecord: UILabel!
    @IBOutlet weak var labMyPatient: UILabel!
    @IBOutlet weak var labRecOver: UILabel!
    @IBOutlet weak var labTrash: UILabel!
    
    var arrayBtn = [UIButton]()
    var arrayLine = [UILabel]()
    var colorBtnNormal:UIColor!
    var colorSelected:UIColor!
    
    var contentScroll:UIScrollView!
    
    //历史关键字列表
    var historyKeys: JavaUtilArrayList! = JavaUtilArrayList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTittle("行医生涯")
        setRightBtnTittle("编辑")
        
        isExperience = MessageTools.isExperienceMode()
        
        initTitleBtns()
        initFrameDatas()
        setContentScrollView()
        setContentView()
        setCtrlViewFrame()
        
        searchView.delegate = self
        historyKeyTable.hidden = true
        self.view.addSubview(historyKeyTable)
        
    }

    override func getXibName() -> String {
        return "ExplorationViewController"
    }
    
    //设置view的位置参数
    func initFrameDatas(){
        explorationViewY = lineLabel.frame.size.height + searchView.frame.size.height + titleView.frame.size.height + 70
        contentFrame = CGRectMake(0 , 0 , ScreenWidth , ScreenHeight - explorationViewY)
        contentShowCtrlFrame = CGRectMake(0 , 0 , ScreenWidth , ScreenHeight - explorationViewY - 70)
        scrollFrame = CGRectMake(0 , explorationViewY , ScreenWidth , ScreenHeight - explorationViewY)
        scrollShowCtrlFrame = CGRectMake(0 , explorationViewY , ScreenWidth , ScreenHeight - explorationViewY - 70)
        verLineShowFrame = CGRectMake(60 , explorationViewY , 1 , ScreenHeight - explorationViewY - 68)
        verLineHiddenFrame = CGRectMake(60 , explorationViewY , 1 , ScreenHeight - explorationViewY)
    }
    
    //设置滑动显示内容的scrollview
    func setContentScrollView(){
        let contentWidth = scrollFrame.size.width * CGFloat(arrayBtn.count)
        let contentHeight = scrollFrame.size.height
        scrollContentSize = CGSize(width: contentWidth, height: contentHeight)
        showCtrlContentSize = CGSize(width: contentWidth, height: scrollShowCtrlFrame.size.height)
        contentScroll = UIScrollView(frame: scrollFrame)
        contentScroll.contentSize = scrollContentSize
        contentScroll.pagingEnabled = true
        contentScroll.delegate = self
        self.view.addSubview(contentScroll)
    }
    
    //初始化显示内容的view
    func setContentView(){
        
        explorationView = ExplorationView(frame: setDataFrame(0))
        myPatientView = ExplorationRecView(frame: setDataFrame(1))
        recOverView = ExplorationRecView(frame: setDataFrame(2))
        trashView = ExplorationRecView(frame: setDataFrame(3))
        
        pageViews = [explorationView,myPatientView,recOverView,trashView]
        
        for item in pageViews {
            contentScroll.addSubview(item)
        }
        
        setContentDatas(showViewPosition)
        setContentDatas(showViewPosition + 1)
    }
    
    //设置scroll中内容的frame
    func setDataFrame(index:Int) -> CGRect {
        
        let width = contentFrame.size.width
        var height = contentFrame.size.height
        
        if isCtrlViewShow {
            height = scrollShowCtrlFrame.size.height
        }
        
        return CGRectMake(width * CGFloat(index) , 0 , width , height)
    }
    
    //设置历史搜索记录的tableview
    func setHistoryKeyTable(){
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        let keysCount = Int(historyKeys.size())
        let height = keysCount * 30 > 150 ? 150 : keysCount * 30
        historyKeyFrame = CGRectMake(0 , explorationViewY - titleView.frame.size.height, ScreenWidth ,CGFloat(height))
        historyKeyTable.frame = historyKeyFrame
        historyKeyTable.reloadData()
    }
    
    //添加控制菜单
    func setCtrlViewFrame(){
        ctrlViewShowFrame = CGRectMake(0, ScreenHeight - 70, ScreenWidth, 70)
        ctrlViewHiddenFrame = CGRectMake(0, ScreenHeight, ScreenWidth, 70)
        ctrlView.frame = ctrlViewHiddenFrame
        waitRecCtrlView.frame = ctrlViewHiddenFrame
        trashCtrlView.frame = ctrlViewHiddenFrame
        self.view.addSubview(ctrlView)
        self.view.addSubview(trashCtrlView)
    }
    
    //显示或隐藏底部菜单
    func showOrHiddenCtrlView(){
        
        if isCtrlViewShow {
            isCtrlViewShow = false
            setBtnEnable(true)
            setRightBtnTittle("编辑")
            self.setCtrlViewFrame(self.isCtrlViewShow)
            let view = pageViews[showViewPosition]
            if showViewPosition == getPageViewIndex(explorationView) {
                (view as! ExplorationView).cleanAllSelectedStatus()
            }else{
                (view as! ExplorationRecView).cleanAllSelectedStatus()
            }
            contentScroll.scrollEnabled = true
        }else{
            isCtrlViewShow = true
            setBtnEnable(false)
            setRightBtnTittle("完成")
            self.setCtrlViewFrame(self.isCtrlViewShow)
            contentScroll.scrollEnabled = false
        }
        
    }
    
    //设置底部菜单出现和消失的动画
    func ctrlViewAnimate(isShow:Bool,ctrlView:UIView){
        if isShow {
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                
                ctrlView.frame = self.ctrlViewShowFrame
            }, completion: { (isFinish) -> Void in
                self.contentScroll.frame = self.scrollShowCtrlFrame
                self.contentScroll.contentSize = self.showCtrlContentSize
                self.pageViews[self.showViewPosition].frame = self.setDataFrame(self.showViewPosition)
            })
            
        }else{
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.contentScroll.frame = self.scrollFrame
                self.contentScroll.contentSize = self.scrollContentSize
                ctrlView.frame = self.ctrlViewHiddenFrame
                self.pageViews[self.showViewPosition].frame = self.setDataFrame(self.showViewPosition)
            }, completion: { (isFinish) -> Void in
                    
            })
        }
    }
    
    /**设置底部控制菜单弹出和消失时内容区域的位置*/
    func setCtrlViewFrame(isShow:Bool){
        
        let view = pageViews[showViewPosition]
        
        if showViewPosition == getPageViewIndex(explorationView) {
            (view as! ExplorationView ).isEditStatus = isShow
            (view as! ExplorationView ).timeTableView.reloadData()
            ctrlViewAnimate(isShow,ctrlView: ctrlView)
        }else if showViewPosition == getPageViewIndex(myPatientView) || showViewPosition == getPageViewIndex(recOverView){
            (view as! ExplorationRecView ).isEditStatus = isShow
            (view as! ExplorationRecView ).timeTableView.reloadData()
            ctrlViewAnimate(isShow, ctrlView: ctrlView)
        }else if showViewPosition == getPageViewIndex(trashView) {
            (view as! ExplorationRecView ).isEditStatus = isShow
            (view as! ExplorationRecView ).timeTableView.reloadData()
            ctrlViewAnimate(isShow, ctrlView: trashCtrlView)
        }
    }
    
    /**顶部右侧按钮点击事件*/
    override func onRightBtnOnClick(sender: UIButton) {
        if isExperience {
            MessageTools.experienceDialog(self.navigationController!)
            return
        }
        showOrHiddenCtrlView()
        if showViewPosition == getPageViewIndex(explorationView) {
            explorationView.reloadTable()
        }else if showViewPosition == getPageViewIndex(myPatientView) {
            myPatientView.reloadTable()
        }else if showViewPosition == getPageViewIndex(recOverView) {
            recOverView.reloadTable()
        }else if showViewPosition == getPageViewIndex(trashView) {
            trashView.reloadTable()
        }
    }
    
    //初始化顶部选中按钮
    func initTitleBtns(){
        arrayBtn = [btnMyRecord,btnMyPatient,btnRecOver,btnTrash]
        arrayLine = [labMyRecord,labMyPatient,labRecOver,labTrash]
        colorBtnNormal = UIColor(red:184/255.0,green:184/255.0,blue:184/255.0,alpha:1)
        colorSelected = UIColor(red:41/255.0,green:47/255.0,blue:121/255.0,alpha:1)
        let count = arrayBtn.count
        setBtnSelectedStype(0)
    }
    
    //设置btn和label选中的样式
    func setBtnSelectedStype(index:Int){
        let count = arrayBtn.count
        for i in 0..<count {
            if index == i {
                arrayBtn[i].setTitleColor(colorSelected, forState: UIControlState.Disabled)
                arrayBtn[i].setTitleColor(colorSelected, forState: UIControlState.Normal)
                arrayLine[i].backgroundColor = colorSelected
            }else{
                arrayBtn[i].setTitleColor(colorBtnNormal, forState: UIControlState.Disabled)
                arrayBtn[i].setTitleColor(colorBtnNormal, forState: UIControlState.Normal)
                arrayLine[i].backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    //获取Btn在array中的位置
    func getBtnIndex(btn:UIButton) -> Int{
        
        for (index,item) in arrayBtn.enumerate() {
            if item == btn {
                return index
            }
        }
        return 0
    }
    
    //获取某个view的位置
    func getPageViewIndex(view:UIView) -> Int{
    
        for (index,item) in pageViews.enumerate() {
            if item == view {
                return index
            }
        }
        
        return 0
    }
    
    //设置选中按钮是否可以点击
    func setBtnEnable(enable:Bool){
        
        for item in arrayBtn {
            item.enabled = enable
        }
    }
    
    @IBAction func onTitleBtnClick(sender: UIButton) {
        let index = getBtnIndex(sender)
        if index == showViewPosition {
            return
        }
        setBtnSelectedStype(index)
        changePage(index)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let controller = SearchViewController()
        controller.searchKey = searchBar.text
        print("\(searchBar.text)")
        self.navigationController?.pushViewController(controller, animated: true)
        searchBar.resignFirstResponder()
    }
    
    /**分享数据（最近查看列表或者云识别完成列表，根据当前选中的viewpa判断）*/
    @IBAction func sharePatientsClick() {
        if showViewPosition == getPageViewIndex(explorationView) {
            explorationView.shareDatas()
        }else if showViewPosition == getPageViewIndex(myPatientView) {
            myPatientView.shareDatas()
        }else if showViewPosition == getPageViewIndex(recOverView) {
            recOverView.shareDatas()
        }
    }
    
    /**删除数据（最近查看列表或者云识别完成列表，根据当前选中的viewpa判断）*/
    @IBAction func delPatientsClick(sender: AnyObject) {
        if showViewPosition == getPageViewIndex(explorationView) {
            explorationView.delDatas()
        }else if showViewPosition == getPageViewIndex(myPatientView) {
            myPatientView.delDatas()
        }else if showViewPosition == getPageViewIndex(recOverView) {
            recOverView.delDatas()
        }
    }
    
    /**批量恢复垃圾箱中的记录*/
    @IBAction func huifuTrashClick() {
        trashView.huifuDatas()
    }
    
    /**批量删除垃圾箱中的记录*/
    @IBAction func delTrashClick() {
        trashView.delDatas()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel!.text = historyKeys.getWithInt(Int32(indexPath.row)) as? String
        cell.textLabel!.font = UIFont.systemFontOfSize(12.0)
        cell.textLabel!.textColor = UIColor.lightGrayColor()
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(historyKeys.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        setHistoryKeyTable()
        historyKeyTable.hidden = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        historyKeyTable.hidden = true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        historyKeyTable.hidden = true
        let controller = SearchViewController()
        searchView.text = historyKeys.getWithInt(Int32(indexPath.row)) as! String
        controller.searchKey = searchView.text
        self.navigationController?.pushViewController(controller, animated: true)
        searchView.resignFirstResponder()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = Int(floor((scrollView.contentOffset.x * 2.0 + ScreenWidth) / (ScreenWidth * 2.0)))
        
        if showViewPosition != index {
            setBtnSelectedStype(index)
            showViewPosition = index
            
            if index == getPageViewIndex(myPatientView) {
                //如果界面是我得患者，则隐藏编辑按钮，否则显示
                hiddenRightImage(true)
            }else{
                setRightBtnTittle("编辑")
            }
            
            if index != 0 {
                setContentDatas(index - 1)
            }
            if index != pageViews.count - 1 {
                setContentDatas(index + 1)
            }
        }
    }
    
    func changePage(index:Int){
        
        showViewPosition = index
        
        if index == getPageViewIndex(myPatientView) {
            //如果界面是我得患者，则隐藏编辑按钮，否则显示
            hiddenRightImage(true)
        }else{
            setRightBtnTittle("编辑")
        }
        
        let pointX = ScreenWidth * CGFloat(index)
        let pointY = CGFloat(0)
        contentScroll.setContentOffset(CGPoint(x: pointX, y: pointY), animated: true)
        setContentDatas(index)
    }
    
    func setContentDatas(index:Int){
        
        switch index {
            
        case getPageViewIndex(explorationView):
            
            explorationView.cleanDatas()
            explorationView.setDatas(false)
            
        case getPageViewIndex(myPatientView):
            
            myPatientView.cleanDatas()
            myPatientView.getRecRecordLogic(isMyPatient:true)
            
        case getPageViewIndex(recOverView):
            
            recOverView.cleanDatas()
            recOverView.getRecRecordLogic(ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_ALL,isTrash: false)
            
        case getPageViewIndex(trashView):
            
            trashView.cleanDatas()
            trashView.getRecRecordLogic(isTrash: true)
            
        default:
            print("")
        }
        
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        OfflineManager.destoryInstance()
    }
}

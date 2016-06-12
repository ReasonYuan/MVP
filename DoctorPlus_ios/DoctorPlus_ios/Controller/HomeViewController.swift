//
//  HomeViewController.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/29.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

let Home_month_heigth:CGFloat = HomeCollectionView.getMonthViewHeighet()

var mIsFirstLoading:Bool = false

class HomeViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,ComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogicGetUserTotalDataLogic_OnUserTotalDataCallback,ComFqHalcyonLogic2HomeMessageLogic_HomeMessageLogicInterface,SelectMonthControlDelegate,HomeViewDelegate{
    
    @IBOutlet var closeView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var recordsCount: UILabel!
    
    @IBOutlet weak var patientCount: UILabel!
    
    @IBOutlet weak var docCount: UILabel!
    
    @IBOutlet weak var closeTableView: UITableView!
    
    @IBOutlet weak var headBtn: UIButton!
    
    @IBOutlet weak var topMenuScrollView: UIScrollView!
    
    @IBOutlet weak var topSliderView: UIView!
    
    @IBOutlet var topMenuView: UIView!
    
    @IBOutlet weak var mContentView: UIView!
    
    @IBOutlet weak var mHomeView: HomeView!
    
    var mBack2TodayBtn: UIButton!
    
    @IBOutlet weak var mBack2TodayParent: UIView!
    
    @IBOutlet weak var docRenZheng: UIImageView!
    
    var mMonthViewParent: UIView!
    
    @IBOutlet weak var doctorName: UILabel!
    
    @IBOutlet var centerMenuView: UIView!
    
    @IBOutlet weak var yijiahao: UILabel!
    
    @IBOutlet weak var topMenuBarImage: UIImageView!
    
    var topMenuViewState:Bool = false
    
    var mDataArray:JavaUtilArrayList?
    
    var mData:JavaUtilArrayList?
    
    var mMonthViewCache:NSMutableArray!
    
    var mMonthViewInfos:NSMutableArray!
    
    var blurView : UIVisualEffectView?
    
    var mCallbackArray = [Int32: Array<UIButton>]()
    
    var mMonthData:JavaUtilMap?
    
    var mSelectMonthControl:SelectMonthControl?
    
    var userActions:JavaUtilArrayList! = JavaUtilArrayList()
    
    var isCloseViewShow:Bool = false
    
    var currentDayIndex = -1
    
    var reRefresh = false
    
    var mSlectCalendar:JavaUtilCalendar?
    
    @IBOutlet weak var mTakePhoto: UIButton!

    
    init() {
        super.init(nibName: "HomeViewController", bundle: nil)
        mMonthViewParent = UIView()
        if(!PracticeDemo){
            mTakePhoto.hidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func dpNumberBtn(sender: AnyObject) {
        if(ComFqLibToolsConstants.getUser().getDPName() == ""){
            self.navigationController?.pushViewController(SettingPlusIdViewController(), animated: true)
        }else{
            return
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = HomeCollectionView.getMonthViewHeighet()
        mMonthViewParent.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
        
        mBack2TodayBtn.frame = CGRectMake(0, 0, mBack2TodayParent.frame.size.width, mBack2TodayParent.frame.size.height)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /**初始化IMSDK**/
        
        mHomeView.delegate = self
        self.view.addSubview(mMonthViewParent)
        mMonthViewParent.clipsToBounds = true
        self.view.insertSubview(mMonthViewParent, belowSubview: mBack2TodayParent)
        mBack2TodayBtn = UIButton(type: UIButtonType.Custom)
        mBack2TodayBtn.backgroundColor = UIColor.clearColor()
        mBack2TodayBtn.setImage(UIImage(named:"home_botton_right_icon.png"), forState: UIControlState.Normal)
        mBack2TodayBtn.addTarget(self, action: "onBack2TodayBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        mBack2TodayParent.addSubview(mBack2TodayBtn)
        mBack2TodayBtn.hidden = true
        let recognizer:UISwipeGestureRecognizer! = UISwipeGestureRecognizer(target: self, action: "handleSwipeFrom:")
        recognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(recognizer)
        mHomeView.collectionView.delegate = self
        mHomeView.collectionView.dataSource = self
        
        UITools.setBorderWithView(1.0, tmpColor: Color.color_emerald.CGColor, view: headBtn)
        
        
        topMenuScrollView.contentSize = CGSizeMake(ScreenWidth, 300)
        centerMenuView.frame = CGRectMake(0, 0, ScreenWidth, 300)
        topMenuScrollView.addSubview(centerMenuView)
        
        
        mMonthViewCache = NSMutableArray()
        mMonthViewInfos = NSMutableArray()
        mHomeView.collectionView.registerNib(UINib(nibName: "HomeViewHeaderCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "headerCell")
        mHomeView.collectionView.registerNib(UINib(nibName: "HomeViewEmptyCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "emptyCell")
        mHomeView.collectionView.registerNib(UINib(nibName: "HomeViewMoreCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "moreCell")
        mHomeView.collectionView.registerNib(UINib(nibName: "HomeViewItemCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "itemCell")
        
        topMenuView.frame = CGRectMake(0, -(ScreenHeight - 50), ScreenWidth, ScreenHeight)
        //        topMenuView.alpha = 0.95
        self.view.addSubview(topMenuView)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        topSliderView.addGestureRecognizer(tapGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        topSliderView.addGestureRecognizer(swipeGesture)
        
        topSliderView.userInteractionEnabled = true
        
        ComFqHalcyonLogicGetUserTotalDataLogic().requestUserTotalDataWithComFqHalcyonLogicGetUserTotalDataLogic_OnUserTotalDataCallback(self)
        
        //closeView
        nameLabel.text = ComFqLibToolsConstants.getUser().getName()

        ComFqHalcyonLogic2DoctorHomeLogic().requestPatientMonthWithComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback(self)
        
        userActions = ComFqLibUserActionManger.getInstance().getCloseViewActions()
        
        
    }

    
    /**上拉监听*/
    func handleSwipeFrom(recognizer:UISwipeGestureRecognizer){
        if isCloseViewShow{
            return
        }
        if !topMenuViewState {
            isCloseViewShow = true
            closeTableView.reloadData()
            closeView.frame = CGRectMake(0, 0, ScreenWidth, 1400 + CGFloat(userActions!.size()*120))
            self.view.addSubview(closeView)
            var time:NSTimeInterval!
            time = 5.0*((1400 + Double(userActions!.size()*120)) / 1400)
            
            UIView.animateWithDuration(time, animations: { () -> Void in
                self.closeView.frame = CGRectMake(0, -1400 + ScreenHeight - CGFloat(self.userActions!.size()*120) , ScreenWidth, 1400 + CGFloat(self.userActions!.size()*120))
                }, completion: { (state) -> Void in
                    //                    self.closeView.removeFromSuperview()
                    var timer:NSTimer! = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "timerFired:", userInfo: nil, repeats: false)
            })
            
        }
        
    }
    func timerFired(timer:NSTimer){
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.closeView.alpha = 0
            }, completion: { (state) -> Void in
                self.isCloseViewShow = false
                self.closeView.removeFromSuperview()
                self.closeView.alpha = 1
        })
        timer.invalidate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let photo:ComFqHalcyonEntityPhoto = ComFqHalcyonEntityPhoto(int:ComFqLibToolsConstants.getUser().getImageId(),withNSString: "")
        headBtn.downLoadImageWidthImageId(photo.getImageId(), callback: { (view, path) -> Void in
            let tmpBtn = view as! UIButton
            tmpBtn.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
        })
        
        doctorName.text = ComFqLibToolsConstants.getUser().getName()
        if(ComFqLibToolsConstants.getUser().getDPName() == ""){
            yijiahao.textColor = UIColor.redColor()
            yijiahao.text = "未设置"
        }else{
            yijiahao.textColor = Color.color_emerald
            yijiahao.text = ComFqLibToolsConstants.getUser().getDPName()
        }
        reRefresh = false
        if(mDataArray != nil && mDataArray?.size() > 0){
            if(mDataArray?.size() < 150){
                reRefresh = true
                ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithLong(mDataArray!.getWithInt(0).getTimeMillis(), withInt: 0, withInt: mDataArray!.size(), withComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback: self)
            }else{
                ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback(self)
            }
        }else{
            if(mDataArray == nil) {
                reRefresh = false
            }else{
                reRefresh = true
            }
            ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback(self)
        }
        
        if ComFqHalcyonEntityCertificationStatus.getInstance().getState() == ComFqHalcyonEntityCertificationStatus_CERTIFICATION_PASS {
            docRenZheng.hidden = false
        }else{
            docRenZheng.hidden = true
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        messagePos = -1
        getDynamicMessage()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func QrcodeClick(sender: AnyObject) {
        self.navigationController?.pushViewController(MyQrCodeViewController(), animated: true)
    }
    
    func errorMonthWithNSString(msg: String!) {
        
    }
    
    func errorWithNSString(msg: String!) {
        
    }
    
    @IBAction func headClick(sender: AnyObject) {
        self.navigationController?.pushViewController(UserProfileViewController(), animated: true)
    }
    
    func feedHomeDatasWithJavaUtilArrayList(infos:JavaUtilArrayList)
    {
        if ( infos.size() == 0 ) {
            return
        }
        var appendData = false
        
        //TODO: 太多数据会爆内存
        if(mDataArray != nil && mHomeView.isLoading()){
            appendData = true
//            mDataArray?.addAllWithJavaUtilCollection(infos)
        }
//        else{
            mDataArray = infos
//        }
        mData = ComFqHalcyonLogic2DoctorHomeLogic.sortAndGroupWithJavaUtilArrayList(mDataArray)
        
        if(mMonthViewInfos.count > 0){
            for i : Int in 0...mMonthViewInfos.count-1 {
                let info:HomeMonthViewInfo = mMonthViewInfos.objectAtIndex(i) as! HomeMonthViewInfo
                if info.view != nil {
                    self.cacheMonthView(info.view!)
                }
            }
        }
        
        mMonthViewInfos.removeAllObjects()
        let width = self.getItemWidth()
        var next = CGFloat(0)
        if (mData != nil) {
            for i : Int in 0...(Int(mData!.size())-1) {
                let group:JavaUtilArrayList = mData!.getWithInt(Int32(i)) as! JavaUtilArrayList
                var index : CGFloat = CGFloat(i);
                let infoWidth = width * CGFloat(group.size())
                let frame = CGRectMake(next, 0, infoWidth, 0)
                next += infoWidth
                let oneData:ComFqHalcyonEntityHomeOneDayData = group.getWithInt(Int32(0)) as! ComFqHalcyonEntityHomeOneDayData
                let monthVal:String = ComFqLibToolsTimeFormatUtils.getMonthDescriptionWithInt(oneData.getMonth())
                let monthNum:String = Int( oneData.getMonth()  + 1).description
                let info = HomeMonthViewInfo(frame: frame, monthNum: monthNum, monthVal: monthVal)
                mMonthViewInfos.addObject(info)
            }
        }
        self.scrollViewDidScroll(mHomeView.collectionView)
        mHomeView.collectionView.reloadData()

        var dailyRecDat = [Int]()
        for i in 0...(Int(mDataArray!.size())-1){
            let oneData:ComFqHalcyonEntityHomeOneDayData = mDataArray?.getWithInt(Int32(i)) as! ComFqHalcyonEntityHomeOneDayData
            dailyRecDat.append(Int(oneData.getmRecRecongnizedNum()))
//            dailyRecDat.append(Int(arc4random_uniform(100)))
        }
        self.mHomeView.setDailyRecData(dailyRecDat)
        var index = -1
        currentDayIndex = -1
        if(mSlectCalendar != nil){
            index = Int(ComFqHalcyonLogic2DoctorHomeLogic.getFirstDayIndexInMonthWithJavaUtilCalendar(mSlectCalendar, withJavaUtilArrayList: mData))
            mSlectCalendar = nil
        }else{
            index = Int( ComFqHalcyonLogic2DoctorHomeLogic.getCurrentDayIndexWithJavaUtilArrayList(mDataArray))
            currentDayIndex = index
        }
        if(appendData){
            let direct:Alignment = mHomeView.getRefreshDirection()
            if(direct == Alignment.Left){
                mHomeView.scrollToIndex(Int(infos.size()), andAligment: Alignment.Right)
            }else{
                mHomeView.scrollToIndex(0, andAligment: Alignment.Left)
            }
            mHomeView.refreshComplete()
        }else{
            if(!reRefresh) {
                mHomeView.scrollToIndex(index, andAligment: Alignment.Center)
            }
        }
        reRefresh = false
    }
    
    func feedMonthWithJavaUtilMap(data:JavaUtilMap)
    {
        mMonthData = data;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 8
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let row = indexPath.row
        if(row == 7){
            return collectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) 
        }
        
        let oneData:ComFqHalcyonEntityHomeOneDayData = mDataArray?.getWithInt(Int32(indexPath.section)) as! ComFqHalcyonEntityHomeOneDayData
        let itemCount:Int = Int(oneData.getDataCount());
        
        if(row == 0){ //moreView ?
            if(itemCount>=6) {
                let moreCell = collectionView.dequeueReusableCellWithReuseIdentifier("moreCell", forIndexPath: indexPath) as! HomeViewMoreCell
                moreCell.mButton.tag = indexPath.section
                moreCell.mButton.addTarget(self, action: "onMoreButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
                return  moreCell
            }else{
                return  collectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) 
            }
        }
        var cell : UICollectionViewCell!;
        if(row == 6){ //headerView
            cell =  collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) 
            setHeaderView(cell as! HomeViewHeaderCell, data: oneData)
        }else{ //ItemView
            let realIndex = 5 - row
            if(itemCount > realIndex){
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("itemCell", forIndexPath: indexPath) 
                let homeData :ComFqHalcyonEntityHomeData = oneData.getDatas().getWithInt(Int32(realIndex)) as! ComFqHalcyonEntityHomeData
                setItemView(cell as! HomeViewItemCell, data: homeData,IndexPath: indexPath)
            }else{
                return collectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) 
            }
        }
        return cell
    }
    
    func setHeaderView(cell:HomeViewHeaderCell,data:ComFqHalcyonEntityHomeOneDayData){
        cell.reset()
        cell.setWeekText(ComFqLibToolsTimeFormatUtils.getdayOfWeekWithInt((Int32(data.getDayOfWeek()))))
        cell.setMonthText(String(data.getDayOfMonth()))
        
        if(data.getCurrentSate() == ComFqHalcyonEntityHomeOneDayData_CurrSateEnum.values().objectAtIndex(UInt(ComFqHalcyonEntityHomeOneDayData_CurrSate_CURR.rawValue)) as! ComFqHalcyonEntityHomeOneDayData_CurrSateEnum){
            cell.showBg()
        }
    }
    
    func setItemView(cell:HomeViewItemCell,data:ComFqHalcyonEntityHomeData,IndexPath: NSIndexPath){
        cell.reSet()
        cell.showUnreadEffect(!data.isRead())
        cell.tag = IndexPath.section
        let imageId = data.getmImgID()
        let photo = ComFqHalcyonEntityPhoto(int: imageId, withNSString: data.getmImgPath())
        var callbacks:Array<UIButton>? = mCallbackArray[imageId]
        if(callbacks == nil){
            callbacks = Array<UIButton>()
            mCallbackArray[imageId] = callbacks
        }
        mCallbackArray[imageId]!.append(cell.mButton)
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path = data as! NSString
            let callbacks:Array<UIButton>? = self.mCallbackArray[imageId]
            //            var image = UITools.getImageFromFile(path)
            UITools.getThumbnailImageFromFile(path, width: cell.frame.size.width, callback: { (image) -> Void in
                if(callbacks != nil && image != nil){
                    for button:UIButton in callbacks! {
                        if(cell.tag == IndexPath.section){
//                            button.alpha = 0
                            UIView.animateWithDuration(2, animations: { () -> Void in
//                                 button.alpha = 1
                            })
                            button.setBackgroundImage(image, forState: UIControlState.Normal)
                        }
                    }
                    self.mCallbackArray[imageId]?.removeAll(keepCapacity: false)
                }
            })
            
        }), withBoolean: false, withInt: Int32(2))
        cell.mButton.tag = Int(data.getmFollowUpId())
        cell.mButton.addTarget(self, action: "itemClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func itemClick(sender:UIButton) {
        let tag = sender.tag
        let controller = LookFollowUpViewController()
        controller.mTimerId = Int32(tag)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        if (mDataArray != nil) {
            return Int(mDataArray!.size())
        }
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        var width : CGFloat!
        if(indexPath.row == 7){
            width =  Home_month_heigth
        }else{
            width = getItemWidth()
        }
        return CGSizeMake(width,width)
    }
    
    func getItemWidth()->CGFloat{
        return self.mHomeView.collectionView.getItemWidth()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0
    }
    
    
    func onMoreButtonClick(sender:UIButton){
        let controller =  MoreFollowUpViewController()
        let oneData:ComFqHalcyonEntityHomeOneDayData = mDataArray?.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityHomeOneDayData
        controller.Dates =  oneData.getTimeMillis()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onSliderClick(sender: AnyObject) {
        
    }
    
    func cacheMonthView(view:HomeMonthView!){
        view.removeFromSuperview()
        mMonthViewCache.addObject(view)
    }
    
    func getMonthView(info:HomeMonthViewInfo)->HomeMonthView! {
        var view:HomeMonthView!
        if(mMonthViewCache.count > 0){
            view = mMonthViewCache.lastObject as! HomeMonthView
            mMonthViewCache.removeLastObject()
        }else{
            view =  HomeMonthView()
        }
        view.setInfo(info.monthNum, monthVal: info.monthVal)
        view.addTarget(self, action: "onMonthViewClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return view
    }
    
    func onMonthViewClick(sender:HomeMonthView){
        if(mSelectMonthControl == nil){
            let trans = self.blur()
            mSelectMonthControl = SelectMonthControl.create(self.view,data:self.mMonthData,transparent:trans)
            mSelectMonthControl?.delegate = self;
        }
    }
    
    func scrollViewDidScroll(scrollView : UIScrollView){
        let scrollX = scrollView.contentOffset.x
        self.mHomeView.onScroll(scrollX)
        for i:Int in 0 ... mMonthViewInfos.count-1 {
            let info:HomeMonthViewInfo = mMonthViewInfos.objectAtIndex(i) as! HomeMonthViewInfo
            if(info.contain(scrollX,endX:scrollX+scrollView.frame.size.width,contentSizeX:scrollView.contentSize.width)){
                if info.view == nil {
                    info.view = self.getMonthView(info)
                    self.mMonthViewParent.addSubview(info.view!)
                }
                info.offset(scrollX,endX:scrollX+scrollView.frame.size.width)
            }else{
                if info.view != nil {
                    self.cacheMonthView(info.view!)
                    info.view = nil
                }
                
            }
        }
    }
    
    func blur() -> Bool {
        if(IOS_VERSION >= 8){
            if(self.blurView == nil){
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
                self.blurView = UIVisualEffectView(effect: blurEffect)
                self.blurView?.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.view.insertSubview(self.blurView!, belowSubview: self.topMenuView)
                self.topMenuView.backgroundColor = UIColor.clearColor()
                return true
            }
        }else{
            self.topMenuView.backgroundColor = UIColor.whiteColor()
        }
        return false
    }
    
    func unBlur(){
        if(IOS_VERSION >= 8){
            if(self.blurView != nil){
                self.blurView?.removeFromSuperview()
                self.blurView = nil
            }
        }
    }
    
    func showMenuView(){
        self.blur()
        self.blurView?.frame = self.topMenuView.frame
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.topMenuView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
            self.blurView?.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            }, completion: { (state) -> Void in
                self.topMenuViewState = true
                self.topMenuBarImage.image = UIImage(named: "sliding_drawer_handle_bottom_to_up.png")
        })
    }
    
    func hiddenMenuView(){
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.topMenuView.frame = CGRectMake(0, -(ScreenHeight - 50), ScreenWidth, ScreenHeight)
            self.blurView?.frame =  CGRectMake(0, -(ScreenHeight - 50), ScreenWidth, ScreenHeight)
            }, completion: { (state) -> Void in
                self.topMenuViewState = false
                self.topMenuBarImage.image = UIImage(named: "sliding_drawer_handle_bottom_to_down.png")
                self.unBlur()
        })
    }
    
    func handleTap(swipeGesture:UITapGestureRecognizer) {
        print("tap手势")
        if !topMenuViewState {
            showMenuView()
        } else {
            hiddenMenuView()
            
        }
        
    }
    
    func handleSwipe(swipeGesture:UISwipeGestureRecognizer){
        print("handleSwipe手势")
    }
    
    /**云病历库**/
    @IBAction func cloudPatient(sender: AnyObject) {
        self.navigationController?.pushViewController(PatientListViewController(), animated: true)
        
    }
    
    /**随访**/
    @IBAction func followUp(sender: AnyObject) {
        self.navigationController?.pushViewController(FollowUpViewController(), animated: true)
    }
    
    /**设置**/
    @IBAction func setting(sender: AnyObject) {
        self.navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    /**联系人**/
    @IBAction func contacts(sender: AnyObject) {
        self.navigationController?.pushViewController(ContactsViewController(), animated: true)
    }
    
    /**分享**/
    @IBAction func share(sender: AnyObject) {
        print("分享")
        self.navigationController?.pushViewController(ShareViewController(), animated: true)
    }
    
    /**数据可视化Demo**/
    @IBAction func shujukeshihua(sender: AnyObject) {
        print("数据可视化Demo")
        self.navigationController?.pushViewController(DataVisuallizationControllerView(), animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CloseTableViewCell") as? CloseTableViewCell
        
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CloseTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? CloseTableViewCell
        }
        let userAction:ComFqHalcyonEntityUserAction! = userActions.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityUserAction
        cell?.setTextSize(18 + CGFloat(arc4random_uniform(20)), countSize: 14 + CGFloat(arc4random_uniform(10)), statusSize: 18 + CGFloat(arc4random_uniform(20)))
        if indexPath.row%2 == 0 {
            cell?.leftCountLabel.hidden = false
            cell?.leftStatusLabel.hidden = false
            cell?.leftTimeLabel.hidden = false
            cell?.leftCountLabel.text = userAction.getDes()
            cell?.leftStatusLabel.text = userAction.getActionStr()
            cell?.leftTimeLabel.text = userAction.getDateStr()
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(4.0)
            UIView.setAnimationRepeatCount(5)
            UIView.setAnimationRepeatAutoreverses(true)
            cell?.leftView.frame = CGRectMake(cell!.leftView.frame.origin.x+30, cell!.leftView.frame.origin.y+5, cell!.leftView.frame.size.width, cell!.leftView.frame.size.height)
            UIView.commitAnimations()
            cell?.rightView.removeFromSuperview()
            
            
        }else{
            cell?.rightCountLabel.hidden = false
            cell?.rightStatusLabel.hidden = false
            cell?.rightTimeLabel.hidden = false
            cell?.rightCountLabel.text = userAction.getDes()
            cell?.rightStatusLabel.text = userAction.getActionStr()
            cell?.rightTimeLabel.text = userAction.getDateStr()
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(3.0)
            UIView.setAnimationRepeatAutoreverses(true)
            UIView.setAnimationRepeatCount(5)
            cell?.rightView.frame = CGRectMake(cell!.rightView.frame.origin.x-30, cell!.rightView.frame.origin.y-5, cell!.rightView.frame.size.width, cell!.rightView.frame.height)
            UIView.commitAnimations()
            cell?.leftView.removeFromSuperview()
        }
        
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(userActions.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func userDataCallbackWithInt(patientCount: Int32, withInt recordCount: Int32, withInt dpMoney: Int32, withInt friendCount: Int32) {
        let str1 = (recordCount == 0 ? "N/A" : "\(recordCount)")
        let str2 =  (patientCount == 0 ? "N/A" : "\(patientCount)")
        let str3 = (friendCount == 0 ? "N/A" : "\(friendCount)")
        self.recordsCount.text = "总病历数  " + str1
        self.patientCount.text = "总病人数  " + str2
        self.docCount.text = "总医生数  " + str3
    }
    
    
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    var message:String?
    var messagePos:Int32! = -1
    var mMessageList:JavaUtilArrayList!
    
    @IBOutlet weak var right: UIView!
    @IBOutlet weak var left: UIView!
    var firstMessageShow = true
    
    /**message两边的左右效果*/
    func gradientMessageView(){
        let gradientL = CAGradientLayer()
        gradientL.frame = left.bounds
        gradientL.colors = [UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor,UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor,UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0).CGColor]
        gradientL.locations = [0,0.4,0.8]
        gradientL.startPoint = CGPointMake(0, 0)
        gradientL.endPoint = CGPointMake(1 , 0)
        left.layer.addSublayer(gradientL)
        let gradientR = CAGradientLayer()
        gradientR.frame = right.bounds
        gradientR.colors = [UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor,UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).CGColor,UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0).CGColor]
        gradientR.locations = [0,0.4,0.8]
        gradientR.startPoint = CGPointMake(1, 0)
        gradientR.endPoint = CGPointMake(0 , 0)
        right.layer.addSublayer(gradientR)
    }
    
    /**获取动态消息*/
    func getDynamicMessage(){
        if firstMessageShow {
            gradientMessageView()
            firstMessageShow = false
        }
        
//        mIsFirstLoading = true
        if mIsFirstLoading {
            messageView.hidden = false
            self.messageView.frame = CGRectMake(0, 140, ScreenWidth, 0)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1.0)
            UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector("firstLoadingMessageViewAnimationStop")
            self.messageView.frame = CGRectMake(0, 140, ScreenWidth,  20)
            UIView.commitAnimations()

        }else{
            let mHomeMessageLogic:ComFqHalcyonLogic2HomeMessageLogic! = ComFqHalcyonLogic2HomeMessageLogic(comFqHalcyonLogic2HomeMessageLogic_HomeMessageLogicInterface: self)
            mHomeMessageLogic.getMessages()
        }
        mIsFirstLoading = false
    }
    
    
    func firstLoadingMessageViewAnimationStop(){
        message = "欢迎使用医加，助力好医生 Solution For Life!"
        let width = calculateHeightForText(message!)
        self.messageLabel.frame = CGRectMake(ScreenWidth , self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, self.messageLabel.frame.height)
        messageLabel.text = message
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(5.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
        UIView.setAnimationDelegate(self)
//        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDidStopSelector("firstLoadingMessageLabelAnimationStop")
        self.messageLabel.frame = CGRectMake(-width , self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, self.messageLabel.frame.height)
        UIView.commitAnimations()
        

    }
    func firstLoadingMessageLabelAnimationStop(){
        self.messageView.frame = CGRectMake(0, 140, ScreenWidth,  20)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
//        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("firstLoadingAnimationStop")
        self.messageView.frame = CGRectMake(0, 140, ScreenWidth, 0)
        UIView.commitAnimations()
    }
    
    func firstLoadingAnimationStop(){
       messageView.hidden = true

    }
    
    func onHomeMessageDataErrorWithInt(responseCode: Int32, withNSString msg: String!) {
        
    }
    
    func onHomeMessageDataReturnWithJavaUtilArrayList(messageList: JavaUtilArrayList!) {
        mMessageList = messageList
//        mMessageList.addWithId("12313132131")
//        mMessageList.addWithId("5464631318464561")
        if mMessageList.size() > 0 {
            messageView.hidden = false
            self.messageView.frame = CGRectMake(0, 140, ScreenWidth,  0)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1.0)
            UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
//            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector("messageViewAnimationStop")
            self.messageView.frame = CGRectMake(0, 140, ScreenWidth,  20)
            UIView.commitAnimations()
        }
        
        
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        
    }
    func messageViewAnimationStop(){
        showMessage(mMessageList)
    }
    
    func showMessage(messageList: JavaUtilArrayList!){
        messagePos = messagePos + 1
        if messageList.size()-1 == messagePos {
            message = messageList.getWithInt(messagePos) as? String
            let width = calculateHeightForText(message!)
             self.messageLabel.frame = CGRectMake(ScreenWidth , self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, self.messageLabel.frame.height)
            messageLabel.text = message
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(5.0)
            UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
             UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector("lastLabelAnimationStop")
//            UIView.setAnimationBeginsFromCurrentState(false)
            self.messageLabel.frame = CGRectMake(-width , self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, self.messageLabel.frame.height)
            UIView.commitAnimations()
            return
        }
        message = messageList.getWithInt(messagePos) as? String
        let width = calculateHeightForText(message!)
         self.messageLabel.frame = CGRectMake(ScreenWidth , self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, self.messageLabel.frame.height)
        messageLabel.text = message
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(5.0)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
        UIView.setAnimationDidStopSelector("labelAnimationStop")
//        UIView.setAnimationBeginsFromCurrentState(false)
        self.messageLabel.frame = CGRectMake(-width , self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, self.messageLabel.frame.height)
        UIView.commitAnimations()
        
    }
    
    func labelAnimationStop(){
        showMessage(mMessageList)
    }
    
    func lastLabelAnimationStop(){
         self.messageView.frame = CGRectMake(0, 140, ScreenWidth, 20)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
//        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("messageAnimationStop")
        self.messageView.frame = CGRectMake(0, 140, ScreenWidth, 0)
        UIView.commitAnimations()
    
    }
    func messageAnimationStop(){
        messageView.hidden = true
    }
    
    
    /**计算文字宽度*/
    func calculateHeightForText(text:String) -> CGFloat{
        let contentLabel = UILabel(frame: CGRectMake(49, 38, ScreenWidth, 20))
        contentLabel.font = UIFont.systemFontOfSize(12.0)
        contentLabel.numberOfLines = 0
        
        
        contentLabel.text = text
        contentLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let height = contentLabel.frame.size.height
        let contentString:NSString = contentLabel.text!
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT), height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        let contentWidth = contentLableSize.width
        return contentWidth
    }

    func didSelectedYear(year: Int, andMonth month: Int) {
        let index = ComFqHalcyonLogic2DoctorHomeLogic.getFirstDayIndexInMonthWithInt(Int32(year), withInt: Int32(month), withJavaUtilArrayList: mData)
        if( index >= 0 ){
            mHomeView.scrollToIndex(Int(index), andAligment: Alignment.Left);
        }else{
            mSlectCalendar = ComFqHalcyonLogic2DoctorHomeLogic.getCalendarWithInt(Int32(year), withInt: Int32(month))
            ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithLong(ComFqHalcyonLogic2DoctorHomeLogic.getTimeInMillisWithInt(Int32(year), withInt: Int32(month)), withComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback: self)
        }
    }
    
    func willRemovedFromSuperView() {
       
    }
    
    func didRemovedFromSuperView() {
        self.unBlur()
        mSelectMonthControl = nil
    }
    
    func leftCanRefresh() -> Bool {
        if(mDataArray != nil && mDataArray?.size()>0){
           return mDataArray?.getWithInt(0).getTimeMillis() >  ComFqHalcyonLogic2DoctorHomeLogic.getMinMonthTimeWithJavaUtilMap(mMonthData)
        }
        return false
    }
    
    func rightCanRefresh() -> Bool {
        if(mDataArray != nil && mDataArray?.size()>0){
            return mDataArray?.getWithInt(mDataArray!.size() - 1).getTimeMillis() < Int64(NSDate().timeIntervalSince1970*1000)
        }
        return false
    }
    
    func showBack2HomeButton(){
        if(mBack2TodayBtn.hidden){
            self.mBack2TodayBtn.hidden = false
            let parentView :UIView! = mBack2TodayBtn.superview
            self.mBack2TodayBtn.frame = CGRectMake(parentView.frame.size.width / 2.0 - 1.0,parentView.frame.size.height / 2.0 - 1.0, 2, 2)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.mBack2TodayBtn.alpha = 1
                self.mBack2TodayBtn.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)
            })
        }
    }
    
    func hideBack2HomeButton(){
        if(!mBack2TodayBtn.hidden){
            let parentView :UIView! = mBack2TodayBtn.superview
            self.mBack2TodayBtn.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.mBack2TodayBtn.alpha = 0
                self.mBack2TodayBtn.frame = CGRectMake(parentView.frame.size.width / 2.0 - 1.0,parentView.frame.size.height / 2.0 - 1.0, 2, 2)
                }, completion: { (success) -> Void in
                self.mBack2TodayBtn.hidden = true
            })
        }
    }
    
    
    func onLeftRefresh() {
        ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithLong(mDataArray!.getWithInt(0).getTimeMillis() , withInt: 60, withInt: 0, withComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback: self)
    }
    
    func onRightRefresh() {
        ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithLong(mDataArray!.getWithInt(mDataArray!.size()-1).getTimeMillis() , withInt: 0, withInt: 60, withComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback: self)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.onScrollEnd()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
       
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
         mHomeView.scrollViewDidEndDragging(scrollView)
         self.onScrollEnd()
    }
    
    func onScrollEnd(){
        if(currentDayIndex >= 0){
            let frameSize = self.view.frame.size
            let itemWidth = mHomeView.collectionView.getItemWidth()
            let halfItemWidth = itemWidth / 2.0
            let centerX = itemWidth * CGFloat(currentDayIndex) + halfItemWidth
            let pointInViewX:CGFloat =  mHomeView.collectionView.convertPoint(CGPointMake(centerX, 0), toView: self.view).x
            if(pointInViewX > (frameSize.width/2.0 - halfItemWidth) && pointInViewX < (frameSize.width/2.0 + halfItemWidth)){
                self.hideBack2HomeButton()
            }else{
                self.showBack2HomeButton()
            }
        }else{
             self.showBack2HomeButton()
        }
    }
    
   
    func onBack2TodayBtnClick(sender: AnyObject) {
        if(currentDayIndex > 0){
            self.mHomeView.scrollToIndex(currentDayIndex, andAligment: Alignment.Center)
        }else{
            ComFqHalcyonLogic2DoctorHomeLogic().requestPatientsWithComFqHalcyonLogic2DoctorHomeLogic_OnDoctorHomeCallback(self)
        }
        
    }
    
    @IBAction func demoTakePhoto(sender: AnyObject) {
//        self.navigationController?.pushViewController(TakePhotoViewController(), animated: true)
        self.navigationController?.pushViewController(MoreChatListViewController(), animated: true)
    }
    
      @IBAction func toTrash(sender: AnyObject) {
        self.navigationController?.pushViewController(TrashViewController(), animated: true)
    }
}

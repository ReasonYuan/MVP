//
//  ReportChartViewController.swift
//  Care
//
//  Created by reason on 15/8/25.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

//import Foundation
import UIKit

class ReportCell:UITableViewCell{
    
    @IBOutlet weak var lable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lable.numberOfLines = 0
    }
    
    class func meareHeight(string:String?,fontSize:CGFloat = 17) -> CGFloat{
        if let str = string {
            let width = UIScreen.mainScreen().bounds.size.width
            let font = UIFont.systemFontOfSize(fontSize)
            var height =  Tools.measureText(str, font: font, width: width)
            if(height < 40) {
                height = 40
            }
            return height
        }
        return 40

    }
}

class ReportChartViewController: BaseViewController ,iCarouselDelegate ,iCarouselDataSource,HalcyonHttpResponseHandle_HalcyonHttpHandleDelegate,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2GetRecordItemLogic_RecordItemCallBack{
    var carousel:iCarousel!
    var persionChart:PersionChart!
    var logic:ComFqHalcyonLogicCareReportChartLogic! 
    var relationShip:ComFqHalcyonEntityPracticeMyRelationship!
    var reports:NSArray?
    var showIndex:Int = 0
    var showDiagnosis:Bool = false
    var reprotLogic:ComFqHalcyonLogic2GetRecordItemLogic!
    private var noteInfo:JSON? //综合诊断所用数据
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var diagnosisTitle: UILabel!
    @IBOutlet weak var silderView: UIView!
    @IBOutlet var diagnosisView: UIView!
    @IBOutlet weak var arrowDown: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var chartContentView: UIView!
    
    override func getXibName() -> String {
        return "ReportChartViewController"
    }
    
    func doRecordItemBackWithComFqHalcyonEntityRecordItem(recordItem: ComFqHalcyonEntityRecordItem!) {
        if let info = recordItem?.getNoteStr() {
            noteInfo = JSON(data: info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            tableview.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if let info = noteInfo {
            return info.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var cell:ReportCell = UINib(nibName:"ReportCell", bundle:NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil)[0] as! ReportCell
        if let info = noteInfo?[section] {
            for (key,value) in info {
                if(key != "index") {
                    return ReportCell.meareHeight(key, fontSize: 18)                }
            }
        }
        return 44
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let info = noteInfo?[indexPath.section] {
            for (key,value) in info {
                if(key != "index") {
                    var str = value.string
                    return ReportCell.meareHeight(str)
                }
            }
        }
        return 44
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell:ReportCell = UINib(nibName:"ReportCell", bundle:NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil)[0] as! ReportCell
        if let info = noteInfo?[section] {
            for (key,value) in info {
                if(key != "index") {
                    cell.lable.text = key
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if let info = noteInfo?[section] {
            for (key,value) in info {
                if(key != "index") {
                    return key
                }
            }
        }
        return String(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:ReportCell = tableView.dequeueReusableCellWithIdentifier("ReportCell") as! ReportCell
        if let info = noteInfo?[indexPath.section] {
            for (key,value) in info {
                if(key != "index") {
                    var str = value.string
                    cell.lable.text = str
                }
            }
        }
        return cell
    }
    
    func handleErrorWithInt(errorCode: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        
    }
    

    func handleSuccessWithId(object: AnyObject!) {
        if let rep = object as? JavaUtilArrayList{
            reports = Tools.toNSarray(rep)
            showIndex = 0
            self.setData()
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.backgroundView = nil
        reprotLogic = ComFqHalcyonLogic2GetRecordItemLogic(comFqHalcyonLogic2GetRecordItemLogic_RecordItemCallBack: self)
        tableview.registerNib(UINib(nibName:"ReportCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier: "ReportCell")
        arrowDown.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        let readColor = Tools.colorWithHexString("#f56f6c")
        leftText.textColor = readColor
        leftBtn.setImage( Tools.image(UIImage(named: "icon_topleft.png") , withTintColor: readColor), forState: UIControlState.Normal)
        self.setRightBtnTittle("病例档案")
        let icon = UIImageView(image: UIImage(named: "report_icon"))
        icon.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 89, 37, 9.5, 12.5)
        self.TopBar.addSubview(icon)
        self.setRightBtnTitleColor(readColor)
        let halfWidth = UIScreen.mainScreen().bounds.size.width / 2.0
        
        persionChart = PersionChart.create()
        persionChart.showOrgan("")
        persionChart.translatesAutoresizingMaskIntoConstraints = false
        chartContentView.addSubview(persionChart)
        chartContentView.addConstraint(NSLayoutConstraint(item: persionChart, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: halfWidth))
        chartContentView.addConstraint(NSLayoutConstraint(item: persionChart, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UIScreen.mainScreen().bounds.size.height - 188))
        chartContentView.addConstraint(NSLayoutConstraint(item: persionChart, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: chartContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        chartContentView.addConstraint(NSLayoutConstraint(item: persionChart, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: chartContentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        logic =  ComFqHalcyonLogicCareReportChartLogic(halcyonHttpResponseHandle_HalcyonHttpHandleDelegate: self)
        //FIXME
        if let rela = relationShip {
            setTittle(rela.getRelName())
            logic.getRreportWithInt(Int32(rela.getPatientId()), withInt: Int32(1))
        }
        
        diagnosisView.translatesAutoresizingMaskIntoConstraints = false
        let view = self.view
        view.addSubview(diagnosisView)
        view.addConstraint(NSLayoutConstraint(item: diagnosisView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: diagnosisView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant:UIScreen.mainScreen().bounds.size.height))
        view.addConstraint(NSLayoutConstraint(item: diagnosisView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: diagnosisView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -40))
        
        let gister = UITapGestureRecognizer()
        gister.numberOfTapsRequired = 1
        gister.numberOfTouchesRequired  = 1
        gister.addTarget(self, action: "tap")
        silderView.addGestureRecognizer(gister)
        let swipeGisterUp = UISwipeGestureRecognizer()
        swipeGisterUp.addTarget(self, action: "swipe:")
        swipeGisterUp.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(swipeGisterUp)
        let swipeGisterDown = UISwipeGestureRecognizer()
        swipeGisterDown.addTarget(self, action: "swipe:")
        swipeGisterDown.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeGisterDown)
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        if showDiagnosis {
            self.tap()
        }else{
            super.onLeftBtnOnClick(sender)
        }
    }
    
    func swipe(gister:UISwipeGestureRecognizer){
        switch gister.direction{
        case UISwipeGestureRecognizerDirection.Up :
            if(!self.showDiagnosis){
                self.tap()
            }
            break
        case UISwipeGestureRecognizerDirection.Down:
            if(self.showDiagnosis){
                self.tap()
            }
            break
        default:
            break
        }
    }
    
    func tap(){
        UIView.animateWithDuration(Double(0.5), animations: { () -> Void in
            let screenSize = UIScreen.mainScreen().bounds.size
            if self.showDiagnosis {
                let frame = self.diagnosisView.frame
                self.diagnosisView.frame = CGRectMake(0, screenSize.height - 40, screenSize.width, frame.size.height )
                self.arrowDown.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            }else{
                self.diagnosisView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height )
                self.arrowDown.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            }
            self.showDiagnosis = !self.showDiagnosis
        }) { (finished) -> Void in
            self.diagnosisTitle.hidden = self.showDiagnosis
        }
    }
    
    func reloadData(){
        let halfWidth = UIScreen.mainScreen().bounds.size.width / 2.0
        var height = 289 * halfWidth / 157.0
        
        //底部 118 topBar 70
        if (UIScreen.mainScreen().bounds.size.height - 188) < height {
            var sde = UIScreen.mainScreen().bounds.size.height
            height = UIScreen.mainScreen().bounds.size.height - 188
        }
        
        if carousel != nil {
            carousel.removeFromSuperview()
            carousel = nil
        }
        carousel = iCarousel(frame: CGRectMake(halfWidth, 0, halfWidth, height))
        
        self.carousel.dataSource = self
        self.carousel.type = iCarouselType.Custom
        self.carousel.bounceDistance = 0.2
        self.carousel.vertical = true
        carousel.clipsToBounds = true
        
        carousel.backgroundColor = UIColor.clearColor()
        
        carousel.translatesAutoresizingMaskIntoConstraints = false
        chartContentView.addSubview(carousel)
        chartContentView.addConstraint(NSLayoutConstraint(item: carousel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: halfWidth))
        chartContentView.addConstraint(NSLayoutConstraint(item: carousel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: height))
        chartContentView.addConstraint(NSLayoutConstraint(item: carousel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: chartContentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        chartContentView.addConstraint(NSLayoutConstraint(item: carousel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: chartContentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        self.carousel.delegate = self
        let count = self.numberOfItemsInCarousel(carousel)
        self.carousel.scrollToItemAtIndex(count/2, animated: false)
       
    }
    
    
    func setData(){
        self.reloadData()
        if let rep = reports {
            if (showIndex < 0 || showIndex > rep.count-1) {
               return
            }
            if let data = rep[showIndex] as? ComFqHalcyonEntityCareMedicalReport {
                date.text = data.getCheckTime()
                totalScore.text = "总体评分：" + data.getOverallScore()
                reprotLogic.loadRecordItemWithInt(data.getOverallInfoId(), withBoolean: false)
            }
        }
    }
    
    @IBAction func next(sender: AnyObject) {
        if let rep = reports {
            if (showIndex < rep.count-1) {
                showIndex += 1
                self.setData()
            }
        }
    }
    
    @IBAction func last(sender: AnyObject) {
        if let rep = reports {
            if (showIndex >= 1) {
                showIndex -= 1
                self.setData()
            }
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        
        //FIXME 设置id
        let item:ComFqHalcyonEntityPracticePatientAbstract = ComFqHalcyonEntityPracticePatientAbstract()
        let controller = ExplorationRecordListViewController()
        controller.patientItem = item
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        if(index == carousel.currentItemIndex){
            if let rep = reports {
                if (showIndex >= 0  || showIndex <= rep.count-1) {
                    if let data = rep[showIndex] as? ComFqHalcyonEntityCareMedicalReport {
                        if let items = data.getMedicalItems() {
                            if let item = items.getWithInt(Int32(index)) as? ComFqHalcyonEntityCareMedicalItem {
                                let controller = ReportDocumentViewController()
                                controller.medicalItem = item
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                }
            }
            
        }

    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
//        println("----\(carousel.currentItemIndex)---")
//        let parts = ["头部","颈部","胸部","心脏","腹部","上腹部","下腹部","膝盖"];
//        var index:Int = Int(arc4random_uniform(8))
//        persionChart.showOrgan(parts[index])
        if let rep = reports {
            if (showIndex >= 0  || showIndex <= rep.count-1) {
                if let data = rep[showIndex] as? ComFqHalcyonEntityCareMedicalReport {
                    if let items = data.getMedicalItems() {
                        if let item = items.getWithInt(Int32(carousel.currentItemIndex)) as? ComFqHalcyonEntityCareMedicalItem {
                            persionChart.showOrgan(item.getCheckPosition())
                        }
                    }
                }
            }
        }

    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
        if let rep = reports {
            if (showIndex < 0 || showIndex > rep.count-1) {
                return 0
            }
            if let data = rep[showIndex] as? ComFqHalcyonEntityCareMedicalReport {
                if let items = data.getMedicalItems() {
                    return Int(items.size())
                }else{
                    return 0
                }
            }
        }

        return 0
    }
    
    func carouselItemWidth(carousel: iCarousel!) -> CGFloat {
        return carousel.frame.size.width
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        var cardView:ReportCardView!
        if let tmpView = view as? ReportCardView{
           cardView = tmpView
        }else{
            cardView = ReportCardView(frame: CGRectMake(0, 0, carousel.frame.size.width, carousel.frame.size.height * 51 / 289))
        }
        if let rep = reports {
            if (showIndex >= 0  || showIndex <= rep.count-1) {
                if let data = rep[showIndex] as? ComFqHalcyonEntityCareMedicalReport {
                    if let items = data.getMedicalItems() {
                        if let item = items.getWithInt(Int32(index)) as? ComFqHalcyonEntityCareMedicalItem {
                            cardView.score = item.getCheckScore()
                            cardView.lable.text = item.getTypeName()
                        }
                    }
                }
            }
            
        }
        return cardView
    }
    
//    func carousel(carousel: iCarousel!, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
//        return iCarousel.carousel(carousel, itemTransformForOffset: offset, baseTransform: transform)
//    }
    
    func carousel(carousel: iCarousel!, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D, itmeView view: UIView!) -> CATransform3D {
        return iCarousel.carousel(carousel, itemTransformForOffset: offset, baseTransform: transform, itmeView: view)
    }
}
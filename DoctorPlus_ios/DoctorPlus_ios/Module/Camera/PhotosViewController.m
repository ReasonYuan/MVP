//
//  PhotosViewController.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "PhotosViewController.h"
#import "ChartView.h"
#import "HomeGetChartDataLogic.h"
#import "Tools.h"
#import "PhotosCell.h"
#import "PhotosManager.h"
#import "ScannerViewController.h"
#import "PhotoRecord.h"
#import "UIImage+Thumbnail.h"
#import "DoctorPlus_ios-Swift.h"
#import "UICollectionView+Draggable.h"
#import "UICollectionViewLayout_Warpable.h"

#define  SPACING 10
#ifndef  isPad
    #define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif


@interface PhotosViewController () <UICollectionViewDataSource_Draggable,UICollectionViewDelegateFlowLayout,PhotosGroupLargeCellDelegate,ComFqLibCallbackICallback>
{
    ComFqHalcyonPracticePhotosManager* photoManager;
    BOOL isEditModel;
    NSMutableArray* selectedIndex;
    BrowserPhotosView* browserView;
    PhotosGroupLargeCell* largeCell;
    NSTimer* timer;
    UITapGestureRecognizer* gesture;
}
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *cView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotosViewController

- (void)doCallbackWithId:(id)obj
{
    [photoManager getStatusWithComFqLibCallbackICallback:[[WapperCallback alloc] initOnCallback:^(id success) {
        [_collectionView reloadData];
    }]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"已拍照片"];
    isEditModel = false;
    photoManager = [ComFqHalcyonPracticePhotosManager getInstance];
    photoManager->onStatueChangeCallback_ = self;
    [self setRightBtnTittle:@"整理"];

    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    selectedIndex = [[NSMutableArray alloc] init];
    [photoManager getRecordTextWithComFqHalcyonEntityPhotoRecord:nil withComFqLibCallbackICallback:nil];
    [_bottomView setFrame:CGRectMake(0, screenHeight, screenWidth, 60)];
    [self.view addSubview:_bottomView];
    [photoManager getStatusWithComFqLibCallbackICallback:[[WapperCallback alloc] initOnCallback:^(id success) {
        [_collectionView reloadData];
    }]];
    _collectionView.draggable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewRecContent:) name:@"ViewRecContent" object:nil];
    timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(updateStatues) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapEmpty) name:@"BrowserPhotosViewTapEmpty" object:nil];
    [_collectionView registerNib:[UINib nibWithNibName:@"PhotosNormalCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CELL_IDENTIFY_NORMAL];
    [_collectionView registerNib:[UINib nibWithNibName:@"PhotosGroupCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CELL_IDENTIFY_GROUP];
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapEmpty)];
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
}

-(void)dealloc
{
    photoManager->onStatueChangeCallback_ = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [timer fire];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [timer invalidate];
}

-(void)updateStatues{
    if(![photoManager isAllPhotoComplete]){
        [photoManager getStatusWithComFqLibCallbackICallback:[[WapperCallback alloc] initOnCallback:^(id success) {
            [_collectionView reloadData];
        }]];
    }
}

-(void)viewRecContent:(NSNotification*)obj
{
    NSNumber* arg = (NSNumber*)obj.userInfo[@"isShow"];
    NSInteger isShowImg = arg.integerValue;
    if(isShowImg == 1){
        [self setTitle:@"已拍照片"];
    }else if(isShowImg == 0){
        [self setTitle:@"识别内容"];
    }
}

-(void)onRightBtnOnClick:(UIButton*)sender
{
    isEditModel = !isEditModel;
    if(isEditModel){
        [self setRightBtnTittle:@"完成"];
         _bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, 60);
        [UIView animateWithDuration:.5 animations:^{
            _bottomView.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
        }];
    }else{
        [self setRightBtnTittle:@"整理"];
        [self setTitle:@"已拍照片"];
        if(_bottomView.superview){
            [UIView animateWithDuration:.5f animations:^{
                _bottomView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, 60);
            } completion:^(BOOL finished) {

            }];
        }
    }
    [selectedIndex removeAllObjects];
    [_collectionView reloadData];
    if(isEditModel){
        _collectionView.draggable = NO;
    }else{
        _collectionView.draggable = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setRightBtnTittle:@"整理"];
//     _bottomView.frame = CGRectMake(0, self.view.frame.size.height , _cView.frame.size.width, 60);
    isEditModel = NO;
    [selectedIndex removeAllObjects];
    [_collectionView reloadData];
}



+(CGSize)getCellSize
{
    int column = 3;
    if (isPad) {
        column = 6;
    }
    NSInteger width = ([UIScreen mainScreen].bounds.size.width- SPACING*(column+1)) / (float)column;
    NSInteger height = width * 1.5f;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(SPACING, SPACING, SPACING, SPACING);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [photoManager groupCount];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [PhotosViewController getCellSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSNumber* num = [NSNumber numberWithInteger:index];
    CGSize cellSize = [PhotosViewController getCellSize];
    JavaUtilArrayList* group = [photoManager getGroupWithInt:(int)index];
    if([group size] == 1){
        PhotosNormalCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFY_NORMAL forIndexPath:indexPath];
        ComFqHalcyonEntityPhotoRecord* photo = [group getWithInt:0];
        [cell reset];
        NSInteger state = [photo getState];
        if(state <= 0){
            if(photo -> isLoading_) state = 0;
            else state = -1;
        }
        cell.status = state;
        cell.edit = isEditModel;
        if(cell.status == 2){
            [cell setTime:[photo getProcessTime]];
        }
        cell.ImageView.tag = index;
        cell.ImageView.image = [UIImage createThumbnailImageFromFile:[photo getLocalPath] MaxWidth:cellSize.width UseCache:YES];
        if([selectedIndex containsObject:num]){
            cell.selecte = YES;
        };
        
        return cell;
    }else{
        PhotosGroupCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFY_GROUP forIndexPath:indexPath];
        [cell reset];
        cell.edit = isEditModel;
        cell.data = group;
        if([selectedIndex containsObject:num]){
            cell.selecte = YES;
        };
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(largeCell){
        [largeCell removeFromSuperview];
        [self setBigRightButtonHiden:NO];
        largeCell = nil;
        [_collectionView removeGestureRecognizer:gesture];
        [_collectionView reloadData];
        return;
    }
    UICollectionViewCell* cell = [_collectionView cellForItemAtIndexPath:indexPath];
    if(isEditModel){
        ((PhotosNormalCell*)cell).selecte = !((PhotosNormalCell*)cell).selecte;
        NSNumber* num = [NSNumber numberWithInteger:indexPath.row];
        if(((PhotosNormalCell*)cell).selecte){
            if(![selectedIndex containsObject:num]){
                [selectedIndex addObject:num];
            };
        }else{
            if([selectedIndex containsObject:num]){
                [selectedIndex removeObject:num];
            };
        }
        
    }else{
        if([cell.reuseIdentifier isEqualToString:CELL_IDENTIFY_NORMAL]){
            browserView = [[BrowserPhotosView alloc] initWithFrame:CGRectMake(0, 70, self.containerView.frame.size.width, self.containerView.frame.size.height)];
            [self.view addSubview:browserView];
            NSArray* all = [Tools toNSarray:[photoManager getAllPhotos]];
            NSInteger index = 0;
            for (NSInteger i = 0; i < [photoManager groupCount]; i++) {
                if(indexPath.row == i){
                    break;
                }
                JavaUtilArrayList* group = [photoManager getGroupWithInt:(int)i];
                index += [group size];
            }
            [browserView setDatas:index pagePhotoRecords:all];
            [self setBigRightButtonHiden:YES];
        }else{
            if(!largeCell){
                NSInteger width = self.view.frame.size.width*7/8.f;
                NSInteger heigth = (self.view.frame.size.height-70)*4/5.f;
                largeCell = [[NSBundle mainBundle] loadNibNamed:@"PhotosLargeGroupCell" owner:nil options:nil][0];
                largeCell.frame = CGRectMake((self.view.frame.size.width - width)/2.f, (self.view.frame.size.height - heigth) / 2.f, width, heigth);
                JavaUtilArrayList* group = [photoManager getGroupWithInt:(int)indexPath.row];
                largeCell.data = group;
                largeCell.group = indexPath.row;
                largeCell.delegate = self;
                largeCell.layer.masksToBounds = true;
                largeCell.layer.cornerRadius = 6;
                [self.view addSubview:largeCell];
                [self setBigRightButtonHiden:YES];
                [_collectionView addGestureRecognizer:gesture];
            }
        }
    }

}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [photoManager moveToWithInt:(int)fromIndexPath.row withInt:(int)toIndexPath.row];
}


-(void)onTap:(ComFqHalcyonEntityPhotoRecord*)item
{
    browserView = [[BrowserPhotosView alloc] initWithFrame:CGRectMake(0, 70, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    [self.view addSubview:browserView];
    NSArray* all = [Tools toNSarray:[photoManager getAllPhotos]];
    NSInteger index = 0;
    for (NSInteger i = 0; i < [all count]; i++) {
        if(item == [all objectAtIndex:i]){
            index = i;
            break;
        }
    }
    [browserView setDatas:index pagePhotoRecords:all];
    [self setBigRightButtonHiden:YES];

}

-(void)onLeftBtnOnClick:(UIButton*)sender
{
    [self setTitle:@"已拍照片"];
    if(browserView){
        [browserView removeFromSuperview];
        [self setBigRightButtonHiden:largeCell];
        browserView = nil;
    }else if (largeCell){
        [largeCell removeFromSuperview];
        [self setBigRightButtonHiden:NO];
        largeCell = nil;
        [_collectionView removeGestureRecognizer:gesture];
        [_collectionView reloadData];
    }else if(isEditModel){
        [self onRightBtnOnClick:self.bigRightBtn];
    }
    else{
       [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)onTapEmpty
{
    if(browserView){
        [browserView removeFromSuperview];
        [self setBigRightButtonHiden:largeCell];
        browserView = nil;
    }else if(largeCell){
        [largeCell removeFromSuperview];
        [self setBigRightButtonHiden:NO];
        [_collectionView removeGestureRecognizer:gesture];
        largeCell = nil;
        [_collectionView reloadData];
    }
}


- (IBAction)onMerger:(id)sender {
    if([selectedIndex count] > 1){
        NSNumber* first = [selectedIndex objectAtIndex:0];
        [selectedIndex removeObject:first];
        IOSIntArray* intArray = [IOSIntArray arrayWithLength:[selectedIndex count]];
        for (NSInteger i = 0 ; i < selectedIndex.count ; i++) {
            NSNumber* num = [selectedIndex objectAtIndex:i];
            intArray->buffer_[i] = [num intValue];
        }
        [photoManager mergerWithInt:[first intValue] withIntArray:intArray];
        [self onRightBtnOnClick:self.bigRightBtn];
    }
    
}

-(void)onRemove:(ComFqHalcyonEntityPhotoRecord*)item
{
    [photoManager addPhotoWithComFqHalcyonEntityPhotoRecord:item];
    [_collectionView reloadData];
}

- (IBAction)onDelete:(id)sender {
    
    if([selectedIndex count] > 0){
        IOSIntArray* intArray = [IOSIntArray arrayWithLength:[selectedIndex count]];
        for (NSInteger i = 0 ; i < selectedIndex.count ; i++) {
            NSNumber* num = [selectedIndex objectAtIndex:i];
            intArray->buffer_[i] = [num intValue];
        }
        [photoManager delete__WithIntArray:intArray];
    }
    [self onRightBtnOnClick:self.bigRightBtn];
}

- (IBAction)onMoveTo:(id)sender {
    if([MessageTools isExperienceMode]){
        [MessageTools experienceDialog:self.navigationController];
        return;
    }
    
    if([selectedIndex count] > 0){
    
        IOSIntArray* intArray = [IOSIntArray arrayWithLength:[selectedIndex count]];
        for (NSInteger i = 0 ; i < selectedIndex.count ; i++) {
            NSNumber* num = [selectedIndex objectAtIndex:i];
            intArray->buffer_[i] = [num intValue];
        }
        JavaUtilArrayList* selectArray =  [photoManager getSelectListWithIntArray:intArray];
        for (int i = 0; i < [selectArray size]; i++) {
            JavaUtilArrayList* array =  [selectArray getWithInt:i];
            for (int j = 0 ; j <  [array size]; j++) {
                ComFqHalcyonEntityPhotoRecord* photo = [array getWithInt:j];
                if([photo getState] != ComFqHalcyonEntityPhotoRecord_get_OCR_STATE_COMPLETE()){
                    [[FQToast makeSystem] showToast:@"有未识别的图片，不能归档！" superview:self.view];
                    return;
                }
            }
        }
        SelectPatientViewController* controller = [[SelectPatientViewController alloc] init];
        controller.photoImages = selectArray;
        controller.selectedNumber = [selectArray size];
        [controller setClosure:^(BOOL successed) {
            if(successed){
                if([selectedIndex count] > 0){
                    IOSIntArray* intArray = [IOSIntArray arrayWithLength:[selectedIndex count]];
                    for (NSInteger i = 0 ; i < selectedIndex.count ; i++) {
                        NSNumber* num = [selectedIndex objectAtIndex:i];
                        intArray->buffer_[i] = [num intValue];
                    }
                    [photoManager delete__WithIntArray:intArray];
                    [selectedIndex removeAllObjects];
                    [_collectionView reloadData];
                }
            }else{
                [selectedIndex removeAllObjects];
            }
        }];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else{
//         [self.view makeToast:@"请选择要移动的图片或图片组"];
        [[FQToast makeSystem] showToast:@"请选择要移动的图片或图片组" superview:self.view];
    }
    
}


@end

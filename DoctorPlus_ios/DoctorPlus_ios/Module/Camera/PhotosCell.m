//
//  PhotosCell.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "PhotosCell.h"
#import "PhotosViewController.h"
#import "ScannerViewController.h"
#import "PhotoRecord.h"
#import "UIImage+Thumbnail.h"
#import "PhotosManager.h"
#import "UICollectionView+Draggable.h"
#import "UICollectionViewLayout_Warpable.h"

@interface PhotosNormalCell()
@property (weak, nonatomic) IBOutlet UIImageView *checkbox;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UIView *statusView;

@end

@implementation PhotosNormalCell

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)setEdit:(BOOL)edit
{
    _edit = edit;
    [_checkbox setHidden:!edit];
}

-(void)setSelecte:(BOOL)selecte
{
    _selecte = selecte;
    [_checkbox setImage:[UIImage imageNamed:selecte?@"friend_select.png":@"friend_unselect.png"]];
}

-(void)reset
{
    [self setEdit:NO];
    [self setSelecte:NO];
    _timeText.hidden = YES;
}

-(void)hideStatus:(BOOL)hide
{
    _statusView.hidden = hide;
    if(!hide){
        self.status = _status;
    }
}

-(void)setStatus:(NSInteger)status
{
    _status = status;
    if(_statusImage.hidden)return;
    if(_status < 0){
        _statusImage.image = [UIImage imageNamed:@"photo_status_wait.png"];
        _statusLable.text = @"等待上传";
    }else if(_status == 0){
        _statusImage.image = [UIImage imageNamed:@"photo_status_recording.png"];
        _statusLable.text = @"上传中...";
    }else if (_status == 1){
        _statusImage.image = [UIImage imageNamed:@"photo_status_uoloading.png"];
        _statusLable.text = @"识别中...";
    }else if (_status == 2){
        _statusImage.image = [UIImage imageNamed:@"photo_status_success.png"];
        _statusLable.text = @"已识别";
    }
}

-(void)setTime:(long)time
{
    _timeText.hidden = NO;
    _timeText.text = [NSString stringWithFormat:@"(%lds)",time];
}

@end


@interface PhotosGroupCell() <UICollectionViewDataSource_Draggable,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PhotosGroupCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"PhotosNormalCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CELL_IDENTIFY_NORMAL];
    _collectionView.draggable = NO;
    _collectionView.userInteractionEnabled = NO;
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(void)setData:(JavaUtilArrayList *)data
{
    _data = data;
    [_collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_data){
        return [_data size] > 9 ? 9 : [_data size];
    }
    return 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize parentSize = [PhotosViewController getCellSize];
    int column = 3;
    NSInteger width = (parentSize.width - 10 - 5*(column+1)) / (float)column;
    NSInteger height = (parentSize.height - 10 - 5*(column+1)) / (float)column;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [self collectionView:nil layout:nil sizeForItemAtIndexPath:indexPath];
    PhotosNormalCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFY_NORMAL forIndexPath:indexPath];
    [cell reset];
    [cell hideStatus:YES];
    ComFqHalcyonEntityPhotoRecord* photo = [_data getWithInt:(int)indexPath.row];
    cell.ImageView.image = [UIImage createThumbnailImageFromFile:[photo getLocalPath] MaxWidth:size.width UseCache:YES];
    return cell;
}

-(void)reset
{
    [super reset];
   
}

-(void)hideStatus:(BOOL)hide
{
    
}

@end

@interface PhotosGroupLargeCell()
@end

@implementation PhotosGroupLargeCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.checkbox.hidden = YES;
    self.collectionView.draggable = YES;
    self.collectionView.userInteractionEnabled = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ComFqHalcyonEntityPhotoRecord* item = [self.data getWithInt:(int)indexPath.row];
    if(item && self.delegate){
        [self.delegate onTap:item];
    }
}


- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [ComFqHalcyonPracticePhotosManager moveToWithJavaUtilArrayList:self.data withInt:(int)fromIndexPath.row withInt:(int)toIndexPath.row];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.data){
        return [self.data size];
    }
    return 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize parentSize = self.frame.size;
    int column = 3;
    NSInteger width = (parentSize.width  - 10 - 10*(column+1)) / (float)column;
    NSInteger height = (parentSize.height - 10 - 10*(column+1)) / (float)column;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [self collectionView:nil layout:nil sizeForItemAtIndexPath:indexPath];
    PhotosNormalCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFY_NORMAL forIndexPath:indexPath];
    if (!cell.groupRemoveBtn)
    {
        UIButton* bu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [bu setImage:[UIImage imageNamed:@"photo_group_remove.png"] forState:UIControlStateNormal];
        [cell addSubview:bu];
        cell.groupRemoveBtn = bu;
        [bu addTarget:self action:@selector(onRemove:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell reset];
    [cell.groupRemoveBtn setTag:indexPath.row];
    
    ComFqHalcyonEntityPhotoRecord* photo = [self.data getWithInt:(int)indexPath.row];
    NSInteger state = [photo getState];
    if(state <= 0){
        if(photo -> isLoading_) state = 0;
        else state = -1;
    }
    cell.status = state;
    if(cell.status == 2){
        [cell setTime:[photo getProcessTime]];
    }
    cell.ImageView.image = [UIImage createThumbnailImageFromFile:[photo getLocalPath] MaxWidth:size.width UseCache:YES];
    return cell;
}


-(void)onRemove:(UIButton*)sender
{
    ComFqHalcyonEntityPhotoRecord* item = [self.data getWithInt:(int)[sender tag]];
    [self.data removeWithId:item];
    [self.collectionView reloadData];
    if(item && self.delegate){
        [self.delegate onRemove:item];
    }
}

@end

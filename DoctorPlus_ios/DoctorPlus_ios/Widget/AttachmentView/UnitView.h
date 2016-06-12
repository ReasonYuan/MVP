/*!
 @header    UnitView.h
 @abstract  添加成员animationView
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import <UIKit/UIKit.h>
#import "UnitCell.h"
@protocol UnitViewDelegate<NSObject>

// 通知cell被点击，执行删除操作
- (void) itemDelete:(UnitCell *)unitCell;
- (void) itemClicked:(UnitCell *)unitCell;
@end
@interface UnitView : UIView

/*
    添加一个成员
    icon：成员头像
    name：成员名字
 */
- (void) addNewUnit:(NSString *)icon withName:(NSString *)name;
/*
 @abstract 用于管理成员
 */
@property (nonatomic, strong) NSMutableArray *unitList;
@property (nonatomic, assign) id<UnitViewDelegate>delegate;
@end

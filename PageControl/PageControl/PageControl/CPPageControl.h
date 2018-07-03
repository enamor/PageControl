//
//  CPPageControl.h
//  PageControl
//
//  Created by zhouen on 2018/5/11.
//  Copyright © 2018年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPPageControl,CPPageBarView;
@protocol CPPageControlDelegate <NSObject>
@required

//返回有多少个标题
- (NSInteger)numberOfPageInPageControl:(CPPageControl *)pageControl;

//返回 标题字符串
- (NSString *)pageControl:(CPPageControl *)pageControl titleForIndex:(NSInteger)index;

//返回每个veiw
- (UIView *)pageControl:(CPPageControl *)pageControl itemViewForIndex:(NSInteger)index;

@optional
- (void)pageControl:(CPPageControl *)pageControl willMoveToIndex:(NSInteger)toIndex;
//从 index -> xxx
- (void)pageControl:(CPPageControl *)pageControl movedfromIndex:(NSInteger)fromIndex;

@end

@interface CPPageControl : UIView

@property (nonatomic, weak) id<CPPageControlDelegate> delegate;

/** 标签栏高度 */
@property (nonatomic, assign) CGFloat pageBarHeight;
/** 标签指示器间距 */
@property (nonatomic, assign) CGFloat pageBarMargin;
/** 左右间距 */
@property (nonatomic, assign) CGFloat pageBarOffset_LR;
/** 标签指示器高度 */
@property (nonatomic, assign) CGFloat indicatorHeight;
/** 标签栏背景图片 */
@property (nonatomic, strong) UIImage *pageBarBackgroundImage;
/** 标签栏背景颜色 */
@property (nonatomic, strong) UIColor *pageBarBackgroundColor;
/** 标签颜色 */
@property (nonatomic, strong) UIColor *pageBarTextColor;
/** 标签字体 */
@property (nonatomic, strong) UIFont  *pageBarTextFont;
/** 标签选中颜色 */
@property (nonatomic, strong) UIColor *pageBarSelectColor;
/** 标签指示器颜色 */
@property (nonatomic, strong) UIColor *indicatorColor;

- (void)reloadData;
@end

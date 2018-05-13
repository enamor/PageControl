//
//  CPPageBarItem.h
//  PageControl
//
//  Created by zhouen on 16/9/9.
//  Copyright © 2016年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CHANNEL_MARGIN   10

@class CPPageBarView;
@protocol  CPPageBarItemDelegate<NSObject>

-(void)pageBarView:(CPPageBarView *)view didSelectIndex:(NSUInteger)index;

@end

@interface CPPageBarView : UIView

/** 标签栏高度 */
@property (nonatomic, assign) CGFloat barHeight;
/** 标签栏背景图片 */
@property (nonatomic, strong) UIImage *backgroundImage;
/** 标签颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 字体大小 */
@property (nonatomic, strong) UIFont *font;
/** 标签选中颜色 */
@property (nonatomic, strong) UIColor *selectColor;
/** 标签指示器颜色 */
@property (nonatomic, strong) UIColor *indicatorColor;
/** 标签指示器高度 */
@property (nonatomic, assign) CGFloat indicatorHeight;
/** 标签指示器间距 */
@property (nonatomic, assign) CGFloat itemMargin;
/** 左右间距 */
@property (nonatomic, assign) CGFloat lrOffset;


@property (strong, nonatomic) NSArray <NSString *>*channels;
@property (weak, nonatomic) id<CPPageBarItemDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                  selectColor:(UIColor *)selectColor;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollToPositionByIndex:(NSUInteger)index;


@end

@interface CPPageBarLabel : UILabel

@property (nonatomic, assign) CGFloat textWidth;

+ (instancetype)labelWithTitle:(NSString *)title;

- (void)setupStartColor:(UIColor *)color;
- (void)setupEndColor:(UIColor *)color;

- (void)changeTextColorWithProgress:(CGFloat)progress;

@end

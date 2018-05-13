//
//  CPPageBarItem.m
//  PageControl
//
//  Created by zhouen on 16/9/9.
//  Copyright © 2016年 zhouen. All rights reserved.
//

#import "CPPageBarView.h"

@interface CPPageBarView ()
/** 背景图片 */
@property (nonatomic, strong) UIImageView       *bgImageView;
@property (nonatomic ,strong) UIScrollView      *channelScrollView;
@property (nonatomic ,strong) UIView            *underline;

@property (nonatomic ,strong) UILabel           *selectLabel;
@property (nonatomic ,strong) NSMutableArray    *channelLabels;

/** scrollview是否大于屏幕宽度 */
@property (nonatomic, assign) BOOL isMax;

/// 记录刚开始时的偏移量
@property (nonatomic, assign) NSInteger startOffsetX;


@end

@implementation CPPageBarView

#pragma mark ------ Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                  selectColor:(UIColor *)selectColor {
    if (self = [super initWithFrame:frame]) {
        _selectColor = selectColor;
        _indicatorHeight = 4;
        _font = [UIFont systemFontOfSize:16];
        _itemMargin = 10;
        _lrOffset = 10;
        [self p_initSelf];
    }
    
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame selectColor:[UIColor blueColor]];
}

#pragma mark ------ setter getter

- (void)setChannels:(NSArray <NSString *>*)channels {
    _channels = channels;
    
    _channelLabels = [NSMutableArray arrayWithCapacity:_channels.count];
    [_channelScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_channelScrollView setContentOffset:CGPointZero];
    
    CGFloat totalWitdth = [self textWidth:_channels];
    
    CGFloat margin = 0;
    if (totalWitdth > self.frame.size.width) {
        _isMax = YES;
        margin = _itemMargin;
    } else {
        _isMax = NO;
        margin = (self.frame.size.width - totalWitdth - _lrOffset * 2) / (_channels.count - 1);
    }
    
    [self p_doScrollBarViewFill:margin];
    
}

- (void)p_doScrollBarViewFill:(CGFloat)margin {
    
    CGFloat x = _lrOffset;
    CGFloat h = _channelScrollView.bounds.size.height;
    int i = 0;
    
    for (NSString *channel in _channels) {
        CPPageBarLabel *label = [CPPageBarLabel labelWithTitle:channel];
        label.font = _font;
        label.textColor = _textColor;
        label.tag = i;
        [label setupStartColor:_textColor];
        [label setupEndColor:_selectColor];
        
        [_channelScrollView addSubview:label];
        [self.channelLabels addObject:label];
        
        
        label.frame = CGRectMake(x, 0, label.textWidth, h);
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(p_labelClick:)]];
        if (i == 0) {
            _selectLabel = label;
            label.textColor = _selectColor;

            CGRect rect = label.frame;
            rect.origin.y = rect.size.height - _indicatorHeight;
            rect.size.height = _indicatorHeight;
            
            _underline = [[UIView alloc] initWithFrame:rect];
            _underline.backgroundColor = _indicatorColor;
            [_channelScrollView addSubview:_underline];
        }
        
        
        if (i < _channels.count - 1) {
            x += (label.bounds.size.width + margin);
        } else {
            x += (label.bounds.size.width) + _lrOffset;
        }
        i++;
    }
    
    _channelScrollView.contentSize = CGSizeMake(x, 0);
    
    [self p_scrollToPositionByIndex:0];
}

- (CGFloat)textWidth:(NSArray *)texts {
    CGFloat totalWidth = 0;
    for (NSString *text in texts) {
        CGFloat width = [text sizeWithAttributes:@{NSFontAttributeName:_font}].width + 20;
        totalWidth += width;
    }
    return totalWidth;
}


#pragma mark ------ Public

- (void)scrollToPositionByIndex:(NSUInteger)index {
    [self p_scrollToPositionByIndex:index animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.startOffsetX = scrollView.contentOffset.x;
}

/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // 1、定义获取需要的数据
    CGFloat progress = 0;
    NSInteger originalIndex = 0;
    NSInteger targetIndex = 0;
    NSInteger maxCount = self.channels.count;
    
    // 2、判断是左滑还是右滑
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    
    if (currentOffsetX > self.startOffsetX) { // 左滑
        // 1、计算 progress
        progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
        // 2、计算 originalIndex
        originalIndex = currentOffsetX / scrollViewW;
        // 3、计算 targetIndex
        targetIndex = originalIndex + 1;
        if (targetIndex >= maxCount) {
            progress = 1;
            targetIndex = maxCount - 1;
        }
        // 4、如果完全划过去
        if (currentOffsetX - self.startOffsetX == scrollViewW) {
            progress = 1;
            targetIndex = originalIndex;
        }
    } else { // 右滑
        // 1、计算 progress
        progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        // 2、计算 targetIndex
        targetIndex = currentOffsetX / scrollViewW;
        // 3、计算 originalIndex
        originalIndex = targetIndex + 1;
        
        if (originalIndex >= maxCount) {
            originalIndex = maxCount - 1;
        }
    }
    
    
    CPPageBarLabel *labelLeft  = self.channelLabels[originalIndex];
    CPPageBarLabel *labelRight = self.channelLabels[targetIndex];
    
    // 获取 targetProgress
    CGFloat targetProgress = progress;
    // 获取 originalProgress
    CGFloat originalProgress = 1 - targetProgress;
    
    [labelLeft changeTextColorWithProgress:originalProgress];
    [labelRight changeTextColorWithProgress:targetProgress];
    
    
    CGFloat centerX = labelLeft.center.x   + (labelRight.center.x   - labelLeft.center.x)   * progress ;
    _underline.center = CGPointMake(centerX, _underline.center.y);
    
    CGFloat width = labelLeft.textWidth + (labelRight.textWidth - labelLeft.textWidth) * progress;
    CGRect frame = _underline.frame;
    frame.size.width = width;
    _underline.frame = frame;
    

    //    _underline.centerX = labelLeft.centerX   + (labelRight.centerX   - labelLeft.centerX)   * scaleRight;
    //    _underline.width   = labelLeft.textWidth + (labelRight.textWidth - labelLeft.textWidth) * scaleRight;
}

/** 手指点击smallScrollView */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    // 滚动标题栏到中间位置
    [self p_scrollToPositionByIndex:index];
}


#pragma mark ------ Private

- (void)p_initSelf {
    [self addSubview:self.bgImageView];
    
    self.channelScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_channelScrollView];
    _channelScrollView.showsHorizontalScrollIndicator = NO;
    _channelScrollView.bounces = NO;

}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.bgImageView.hidden = NO;
    self.bgImageView.image = _backgroundImage;
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.channelScrollView.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgImageView.frame = self.bounds;
}



- (void)p_scrollToPositionByIndex:(NSUInteger)index animated:(BOOL)animated{
    if (!_channelLabels || _channelLabels.count == 0 || index >= _channelLabels.count) {
        return;
    }
    CPPageBarLabel *label = self.channelLabels[index];
    
    if (_isMax) {
        CGFloat offsetx   =  label.center.x - _channelScrollView.frame.size.width * 0.5;
        CGFloat offsetMax = _channelScrollView.contentSize.width - _channelScrollView.frame.size.width;
        
        // 在最左和最右时，标签没必要滚动到中间位置。
        if (offsetx < 0)         {offsetx = 0;}
        if (offsetx > offsetMax) {offsetx = offsetMax;}
        if (_channelScrollView.contentSize.width > _channelScrollView.frame.size.width) {
            [_channelScrollView setContentOffset:CGPointMake(offsetx, 0) animated:animated];
        }
    }
    
    _selectLabel.textColor = _textColor;
    label.textColor = _selectColor;
    _selectLabel = label;
    
    CGRect rect = label.frame;
    rect.origin.y = _underline.frame.origin.y;
    rect.size.height = _underline.frame.size.height;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.underline.frame = rect;
        }];
    } else {
        _underline.frame = rect;
    }
    

}

- (void)p_scrollToPositionByIndex:(NSUInteger)index{
    [self p_scrollToPositionByIndex:index animated:YES];
}


- (void)p_labelClick:(UITapGestureRecognizer *)tap{
    CPPageBarLabel *label = (CPPageBarLabel *)tap.view;
    if (_delegate && [_delegate respondsToSelector:@selector(pageBarView:didSelectIndex:)]) {
        [_delegate pageBarView:self didSelectIndex:label.tag];
    }
    
    [self p_scrollToPositionByIndex:label.tag];
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.hidden = YES;
    }
    return _bgImageView;
}








#pragma mark - - - 颜色渐变方法抽取
- (void)p_changeBarTextColorWithProgress:(CGFloat)progress originalLabel:(UILabel *)originalLabel targetLabel:(UILabel *)targetLabel {
//    // 获取 targetProgress
//    CGFloat targetProgress = progress;
//    // 获取 originalProgress
//    CGFloat originalProgress = 1 - targetProgress;
//
//    CGFloat r = self.endR - self.startR;
//    CGFloat g = self.endG - self.startG;
//    CGFloat b = self.endB - self.startB;
//    UIColor *originalColor = [UIColor colorWithRed:self.startR +  r * originalProgress  green:self.startG +  g * originalProgress  blue:self.startB +  b * originalProgress alpha:1];
//    UIColor *targetColor = [UIColor colorWithRed:self.startR + r * targetProgress green:self.startG + g * targetProgress blue:self.startB + b * targetProgress alpha:1];
//
//    // 设置文字颜色渐变
//    originalLabel.textColor = originalColor;
//    targetLabel.textColor = targetColor;
}



@end



@interface CPPageBarLabel ()
/// 开始颜色, 取值范围 0~1
@property (nonatomic, assign) CGFloat startR;
@property (nonatomic, assign) CGFloat startG;
@property (nonatomic, assign) CGFloat startB;
/// 完成颜色, 取值范围 0~1
@property (nonatomic, assign) CGFloat endR;
@property (nonatomic, assign) CGFloat endG;
@property (nonatomic, assign) CGFloat endB;

@end
@implementation CPPageBarLabel

+ (instancetype)labelWithTitle:(NSString *)title {
    CPPageBarLabel *label = [[CPPageBarLabel alloc] init];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    label.userInteractionEnabled = YES;
    
    return label;
}


- (void)changeTextColorWithProgress:(CGFloat)progress {
    
    // 获取 targetProgress
    // CGFloat targetProgress = progress;
    // 获取 originalProgress
    // CGFloat originalProgress = 1 - targetProgress;
    
    CGFloat r = self.endR - self.startR;
    CGFloat g = self.endG - self.startG;
    CGFloat b = self.endB - self.startB;
    
    UIColor *targetColor = [UIColor colorWithRed:self.startR + r * progress green:self.startG + g * progress blue:self.startB + b * progress alpha:1];
    
    self.textColor = targetColor;
}

#pragma mark -- 颜色设置的计算
/// 开始颜色设置
- (void)setupStartColor:(UIColor *)color {
    CGFloat components[3];
    [self getRGBComponents:components forColor:color];
    self.startR = components[0];
    self.startG = components[1];
    self.startB = components[2];
}
/// 结束颜色设置
- (void)setupEndColor:(UIColor *)color {
    CGFloat components[3];
    [self getRGBComponents:components forColor:color];
    self.endR = components[0];
    self.endG = components[1];
    self.endB = components[2];
}

/**
 *  指定颜色，获取颜色的RGB值
 *
 *  @param components RGB数组
 *  @param color      颜色
 */
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, 1);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}


- (CGFloat)textWidth {
    return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width + 20; // +10，要不太窄
}


@end

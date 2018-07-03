//
//  CPPageControl.m
//  PageControl
//
//  Created by zhouen on 2018/5/11.
//  Copyright © 2018年 zhouen. All rights reserved.
//

#import "CPPageControl.h"
#import "CPPageBarView.h"

@interface CPPageControl()<UICollectionViewDelegate, UICollectionViewDataSource, CPPageBarItemDelegate>

/** 存放标签 */
@property (nonatomic, strong) NSMutableArray *titles;

/** 顶部标签view */
@property (nonatomic, strong) CPPageBarView *pageBarView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;



@end

@implementation CPPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self p_init];
        [self p_initSubview];
    }
    return self;
}

- (void)p_init {
    _pageBarHeight = 44;
    _pageBarTextFont = [UIFont systemFontOfSize:20];
    _pageBarBackgroundColor = [UIColor lightGrayColor];
    _pageBarTextColor = [UIColor blackColor];
    _pageBarSelectColor = [UIColor blueColor];
    _indicatorColor = [UIColor blueColor];
    _indicatorHeight = 4;
}

- (void)p_initSubview {
    [self addSubview:self.pageBarView];
    [self addSubview:self.collectionView];
}

- (void)reloadData {
    self.titles = nil;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_delegate) {
        return  [_delegate numberOfPageInPageControl:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *view = view = [_delegate pageControl:self itemViewForIndex:indexPath.row];
    view.frame = cell.bounds;
    [cell addSubview:view];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate) {
        [_delegate pageControl:self willMoveToIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate) {
        [_delegate pageControl:self movedfromIndex:indexPath.row];
    }
    
}


#pragma mark ------ UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        [self.pageBarView scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        [self.pageBarView scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        [self.pageBarView scrollViewWillBeginDragging:scrollView];
    }
}



#pragma mark CPPageBarItemDelegate
- (void)pageBarView:(CPPageBarView *)view didSelectIndex:(NSUInteger)index {
     [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.pageBarView.frame = CGRectMake(0, 0, self.frame.size.width, _pageBarHeight);
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.pageBarView.frame), self.frame.size.width, self.frame.size.height - _pageBarHeight);
    self.flowLayout.itemSize = self.collectionView.bounds.size;
    
    if (_delegate && !_titles) {
        NSInteger count = [_delegate numberOfPageInPageControl:self];
        for (int i = 0; i< count; i++) {
            NSString *title = [_delegate pageControl:self titleForIndex:i];
            [self.titles addObject:title];
        }
        self.pageBarView.channels = self.titles;
    }
}


- (void)setPageBarMargin:(CGFloat)pageBarMargin {
    _pageBarMargin = pageBarMargin;
    self.pageBarView.itemMargin = _pageBarMargin;
}
- (void)setPageBarOffset_LR:(CGFloat)pageBarOffset_LR {
    _pageBarOffset_LR = pageBarOffset_LR;
    self.pageBarView.lrOffset = _pageBarOffset_LR;
}
- (void)setPageBarBackgroundColor:(UIColor *)pageBarBackgroundColor {
    _pageBarBackgroundColor = pageBarBackgroundColor;
    self.pageBarView.backgroundColor = _pageBarBackgroundColor;
}
- (void)setPageBarBackgroundImage:(UIImage *)pageBarBackgroundImage {
    _pageBarBackgroundImage = pageBarBackgroundImage;
    self.pageBarView.backgroundImage = _pageBarBackgroundImage;
}

- (void)setPageBarTextColor:(UIColor *)pageBarTextColor {
    _pageBarTextColor = pageBarTextColor;
    self.pageBarView.textColor = _pageBarTextColor;
}

- (void)setPageBarSelectColor:(UIColor *)pageBarSelectColor {
    _pageBarSelectColor = pageBarSelectColor;
    self.pageBarView.selectColor = _pageBarSelectColor;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    self.pageBarView.indicatorColor = _indicatorColor;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _indicatorHeight = indicatorHeight;
    self.pageBarView.indicatorHeight = _indicatorHeight;
}

- (CPPageBarView *)pageBarView {
    if (!_pageBarView) {
        _pageBarView = [[CPPageBarView alloc] initWithFrame:CGRectZero selectColor:_pageBarSelectColor];
        _pageBarView.delegate = self;
        _pageBarView.backgroundColor = _pageBarBackgroundColor;
        _pageBarView.font = _pageBarTextFont;
        _pageBarView.textColor = _pageBarTextColor;
        _pageBarView.indicatorHeight = _indicatorHeight;
        _pageBarView.indicatorColor = _indicatorColor;
    }
    return _pageBarView;
}

- (NSMutableArray *)titles {
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.bounces = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass(self.class)];
        
        // 设置cell的大小和细节
        flowLayout.itemSize = _collectionView.bounds.size;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        self.flowLayout = flowLayout;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

@end

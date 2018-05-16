//
//  ViewController.m
//  PageControl
//
//  Created by zhouen on 2018/5/11.
//  Copyright © 2018年 zhouen. All rights reserved.
//

#import "ViewController.h"
#import "CPPageControl.h"

@interface ViewController ()<CPPageControlDelegate>

@property (nonatomic, strong) CPPageControl *pageControl;

/** views */
@property (nonatomic, strong) NSMutableDictionary *views;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageControl = [[CPPageControl alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.bounds), self.view.frame.size.height)];
    
    _pageControl.pageBarBackgroundColor = [UIColor grayColor];
    _pageControl.pageBarTextColor = [UIColor greenColor];
    _pageControl.pageBarBackgroundImage = [UIImage imageNamed:@"barbg"];
    _pageControl.pageBarSelectColor = [UIColor redColor];
    _pageControl.pageBarHeight = 44;
    _pageControl.indicatorHeight = 2;
    _pageControl.indicatorColor = [UIColor blueColor];
    _pageControl.pageBarOffset_LR = 5;
   
    
    
    [self.view addSubview:self.pageControl];
    self.pageControl.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}


- (NSInteger)numberOfPageInPageControl:(CPPageControl *)pageControl {
    return 10;
}

- (NSString *)pageControl:(CPPageControl *)pageControl titleForIndex:(NSInteger)index {
    return @"呵呵";
}

- (UIView *)pageControl:(CPPageControl *)pageControl itemViewForIndex:(NSInteger)index {
    NSString *reuseIdentify = @(index).stringValue;
    UIView *view = self.views[reuseIdentify];
    if (!view) {
        view = [UIView new];
        [self.views setObject:view forKey:reuseIdentify];
    }
    
    if (index % 2 == 0) {
        view.backgroundColor = [UIColor grayColor];
    } else {
        view.backgroundColor = [UIColor blueColor];
    }
    
    return view;
}

- (void)pageControl:(CPPageControl *)pageControl movedfromIndex:(NSInteger)fromIndex {
    NSLog(@"fromIndex=%ld  ----------- ",(long)fromIndex);
}

- (NSMutableDictionary *)views {
    if (!_views) {
        _views = [NSMutableDictionary dictionary];
    }
    return _views;
}


@end

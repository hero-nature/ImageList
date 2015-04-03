//
//  ImageSwipeView.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/4.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "ImageSwipeView.h"

@interface ImageSwipeView () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *leftScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *centerScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *rightScrollView;

@end

@implementation ImageSwipeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;    
    
    _leftScrollView.scrollEnabled = _centerScrollView.scrollEnabled = _rightScrollView.scrollEnabled = NO;
    
    _leftScrollView.backgroundColor = [UIColor redColor];
    _centerScrollView.backgroundColor = [UIColor blueColor];
    _rightScrollView.backgroundColor = [UIColor yellowColor];
    self.contentInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds));
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO)
        [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = roundf(scrollView.contentOffset.x / scrollView.bounds.size.width);
    NSLog(@"%ld",(long)page);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resetLoopScroll];
}

- (void)resetLoopScroll {
    CGFloat leftBound = 0;
    CGFloat rightBound = self.contentSize.width - self.frame.size.width;
    
    if (self.contentOffset.x <= -self.bounds.size.width)
    {
        UIColor *color = self.centerScrollView.backgroundColor;
        self.centerScrollView.backgroundColor = self.leftScrollView.backgroundColor;
        self.leftScrollView.backgroundColor = color;
        self.contentOffset = CGPointMake(rightBound, 0);
    }
    else if (self.contentOffset.x >= self.contentSize.width)
    {
        UIColor *color = self.centerScrollView.backgroundColor;
        self.centerScrollView.backgroundColor = self.rightScrollView.backgroundColor;
        self.rightScrollView.backgroundColor = color;
        self.contentOffset = CGPointMake(leftBound, 0);
    }
}

@end

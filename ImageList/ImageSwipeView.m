//
//  ImageSwipeView.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/4.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "ImageSwipeView.h"
#import "AsynImageView.h"

typedef NS_ENUM(NSUInteger, ImageViewPosition) {
    ImageViewPositionLeft,
    ImageViewPositionCenter,
    ImageViewPositionRight,
};

@interface ImageSwipeView () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *leftScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *centerScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *rightScrollView;

@property (nonatomic, strong) NSArray *imagedataSource;
@property (nonatomic) NSInteger currentIndex;

@end

#define sss(X) # X

@implementation ImageSwipeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.currentIndex = 0;
    self.delegate = self;
    [self initImageViews];
    _leftScrollView.scrollEnabled = _centerScrollView.scrollEnabled = _rightScrollView.scrollEnabled = NO;
    [self resetContentInset];
}

- (void)reloadData
{
    [self resetContentInset];
}

- (void)initImageViews
{
    [_leftScrollView addSubview:({
        AsynImageView *imageView = [[AsynImageView alloc] initWithFrame:CGRectZero];
        imageView.tag = 1;
        imageView;
    })];
    [_centerScrollView addSubview:({
        AsynImageView *imageView = [[AsynImageView alloc] initWithFrame:CGRectZero];
        imageView.tag = 1;
        imageView;
    })];
    [_rightScrollView addSubview:({
        AsynImageView *imageView = [[AsynImageView alloc] initWithFrame:CGRectZero];
        imageView.tag = 1;
        imageView;
    })];
}

- (void)resetImages
{
    NSAssert(_swipeViewDataSource, @"must set dataSource");
    
    NSInteger count = [_swipeViewDataSource numberOfImagesInSwipeView:self];
    
    if (self.currentIndex < count) {
        [self imageView:ImageViewPositionCenter loadImageWithURL:[_swipeViewDataSource swipeView:self imageURLAtIndex:self.currentIndex]];
    }
    
    if (self.currentIndex + 1 < count) {
        [self imageView:ImageViewPositionRight loadImageWithURL:[_swipeViewDataSource swipeView:self imageURLAtIndex:self.currentIndex + 1]];
    }
    
    if (self.currentIndex - 1 > 0 && self.currentIndex - 1 < count) {
        [self imageView:ImageViewPositionLeft loadImageWithURL:[_swipeViewDataSource swipeView:self imageURLAtIndex:self.currentIndex - 1]];
    }
}

- (void)resetContentInset
{
    self.contentInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds));
    self.leftScrollView.hidden = self.rightScrollView.hidden = NO;
    self.leftScrollView.zoomScale = self.centerScrollView.zoomScale = self.rightScrollView.zoomScale = 1.0;
    NSInteger count = [_swipeViewDataSource numberOfImagesInSwipeView:self];
    if (self.currentIndex + 1 > count) {
        self.contentInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds), 0, 0);
        self.rightScrollView.hidden = YES;
    }
    if (self.currentIndex - 1 < 0) {
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
        self.leftScrollView.hidden = YES;
    }
    [self resetImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self && decelerate == NO)
        [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self) {
        [self resetLoopScroll];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
{
    if (scrollView != self) {
        return [scrollView viewWithTag:1];
    }
    return nil;
}

- (void)resetLoopScroll {
    CGFloat leftBound = 0;
    CGFloat rightBound = self.contentSize.width - self.frame.size.width;
    
    if (self.contentOffset.x <= -self.bounds.size.width)
    {
        self.contentOffset = CGPointMake(rightBound, 0);
        self.currentIndex --;
        [self resetContentInset];
        if ([_swipeViewDelegate respondsToSelector:@selector(swipeView:didShowImageAtIndex:)]) {
            [_swipeViewDelegate swipeView:self didShowImageAtIndex:self.currentIndex];
        }
    }
    else if (self.contentOffset.x >= self.contentSize.width)
    {
        self.contentOffset = CGPointMake(leftBound, 0);
        self.currentIndex ++;
        if ([_swipeViewDelegate respondsToSelector:@selector(swipeView:didShowImageAtIndex:)]) {
            [_swipeViewDelegate swipeView:self didShowImageAtIndex:self.currentIndex];
        }
        [self resetContentInset];
    }
}

- (void)scrollToImageAtIndex:(NSInteger)index
{
    self.currentIndex = index;
    [self resetContentInset];
}

- (void)imageView:(ImageViewPosition)position loadImageWithURL:(NSString *)imageURLString
{
    AsynImageView *imageView = [self imageViewWithPosition:position];
    __weak typeof(imageView) weakImageView = imageView;
    CGFloat width = CGRectGetWidth(self.bounds);
    [imageView setImageURL:imageURLString placeholderImage:nil decodeType:AsynImageDecodeTypeNormal completion:^(UIImage *image, NSError *error) {
        if (error) {
            return;
        }
        
        __strong typeof(weakImageView)strongImageView = weakImageView;
        if (!strongImageView) {
            return;
        }
        
        if (image) {
            strongImageView.image = image;
            strongImageView.frame = CGRectMake(0, 0, width, image.size.height / image.size.width * width);
        }else{
            NSLog(@"图片资源错误");
        }
    }];
}

- (AsynImageView *)imageViewWithPosition:(ImageViewPosition)position
{
    AsynImageView *view;
    switch (position) {
        case ImageViewPositionLeft:
            view = (id)[_leftScrollView viewWithTag:1];
            break;
        case ImageViewPositionCenter:
            view = (id)[_centerScrollView viewWithTag:1];
            break;
        case ImageViewPositionRight:
            view = (id)[_rightScrollView viewWithTag:1];
            break;
    }
    return view;
}

@end

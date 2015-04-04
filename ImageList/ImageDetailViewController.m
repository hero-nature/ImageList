//
//  ImageDetailViewController.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/4.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "AsynImageCache.h"
#import "ImageSwipeView.h"

@interface ImageDetailViewController () <ImageSwipeViewDataSource, ImageSwipeViewDelegate>
@property (weak, nonatomic) IBOutlet ImageSwipeView *swipeView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic) NSInteger index;
@end

@implementation ImageDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld",(long)_index];
    [_swipeView scrollToImageAtIndex:_index];
}

- (void)setDataSource:(NSArray *)array currentIndex:(NSInteger)index
{
    _dataSource = array;
    _index = index;
}

- (NSString *)swipeView:(ImageSwipeView *)swipeView imageURLAtIndex:(NSInteger)index
{
    return [_dataSource objectAtIndex:index];
}

- (NSInteger)numberOfImagesInSwipeView:(ImageSwipeView *)swipeView
{
    return _dataSource.count;
}

- (void)swipeView:(ImageSwipeView *)swipeView didShowImageAtIndex:(NSInteger)index
{
    self.navigationItem.title = [NSString stringWithFormat:@"%ld",(long)index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [AsynImageCache clearMemoryCache];
}

@end

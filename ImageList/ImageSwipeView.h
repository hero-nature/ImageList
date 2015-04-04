//
//  ImageSwipeView.h
//  ImageList
//
//  Created by Tongtong Xu on 15/4/4.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageSwipeViewDataSource, ImageSwipeViewDelegate;

@interface ImageSwipeView : UIScrollView

@property (nonatomic, weak) IBOutlet id <ImageSwipeViewDataSource> swipeViewDataSource;
@property (nonatomic, weak) IBOutlet id <ImageSwipeViewDelegate> swipeViewDelegate;

- (void)reloadData;

- (void)scrollToImageAtIndex:(NSInteger)index;

@end

@protocol ImageSwipeViewDataSource <NSObject>

- (NSInteger)numberOfImagesInSwipeView:(ImageSwipeView *)swipeView;

- (NSString *)swipeView:(ImageSwipeView *)swipeView imageURLAtIndex:(NSInteger)index;

@end

@protocol ImageSwipeViewDelegate <NSObject>

@optional

- (void)swipeView:(ImageSwipeView *)swipeView didShowImageAtIndex:(NSInteger)index;

@end

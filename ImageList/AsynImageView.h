//
//  AsynImageView.h
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageCache.h"

@interface AsynImageView : UIImageView

- (void)setImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage decodeType:(AsynImageDecodeType)type;

- (void)setImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage decodeType:(AsynImageDecodeType)type completion:(void (^)(UIImage *image, NSError *error))completionBlock;
@end

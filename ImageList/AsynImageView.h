//
//  AsynImageView.h
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsynImageView : UIImageView

- (void)setImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage;

@end

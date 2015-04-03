//
//  AsynImageView.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "AsynImageView.h"
#import "AsynImageCache.h"

@interface AsynImageView ()

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) NSString *imageURL;

@end

@implementation AsynImageView

- (void)setImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage
{
    [self setPlaceholderImage:placeholderImage];
    [self setImageURL:imageURL];
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    if (_placeholderImage == placeholderImage) {
        return;
    }
    _placeholderImage = nil;
    _placeholderImage = placeholderImage;
}

- (void)setImageURL:(NSString *)imageURL
{
    if ([_imageURL isEqualToString:imageURL]) {
        return;
    }

    _imageURL = imageURL;
    
    if(!_imageURL) {
        return;
    }
    
    self.image = self.placeholderImage;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *cachedImage = [AsynImageCache cachedImageWithURL:_imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cachedImage) {
                self.image = cachedImage;
            }else{
                self.image = _placeholderImage;
                [self loadImage];
            }
        });
    });
}

//网络请求图片，缓存到本地沙河中
-(void)loadImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithString:_imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            UIImage *image = [AsynImageCache cacheImageWithData:data imageURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([url isEqualToString:_imageURL]) {
                    self.image = image;
                }
            });
        }
    });
}

@end
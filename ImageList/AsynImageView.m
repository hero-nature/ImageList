//
//  AsynImageView.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "AsynImageView.h"

@interface AsynImageView ()

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) void (^completionBlock)(UIImage *image, NSError *error);
@property (nonatomic) AsynImageDecodeType decodeType;
@end

@implementation AsynImageView

- (void)setImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage decodeType:(AsynImageDecodeType)type
{
    NSString *imageURLString = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _decodeType = type;
    [self setPlaceholderImage:placeholderImage];
    [self setImageURL:imageURLString];
}

- (void)setImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage decodeType:(AsynImageDecodeType)type completion:(void (^)(UIImage *, NSError *))completionBlock
{
    _completionBlock = completionBlock;
    [self setImageURL:imageURL placeholderImage:placeholderImage decodeType:type];
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
    
    if (self.placeholderImage) {
        self.image = self.placeholderImage;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *cachedImage = [AsynImageCache cachedImageWithURL:_imageURL decodeType:self.decodeType];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cachedImage) {
                if (_completionBlock) {
                    _completionBlock (cachedImage, nil);
                }
                self.image = cachedImage;
            }else{
                self.image = _placeholderImage;
                [self loadImage];
            }
        });
    });
}

//网络请求图片，缓存到本地沙河中
- (void)loadImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithString:_imageURL];
        AsynImageDecodeType decodeType = _decodeType;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error && _completionBlock) {
            _completionBlock (nil, error);
        }else {
            UIImage *image = [AsynImageCache cacheImageWithData:data imageURL:url decodeType:decodeType];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([url isEqualToString:_imageURL]) {
                    if (_completionBlock) {
                        _completionBlock(image, nil);
                    }else{
                        self.image = image;
                    }
                }
            });
        }
    });
}

@end
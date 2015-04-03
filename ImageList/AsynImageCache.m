//
//  AsynImageCache.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "AsynImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImage+Resize.h"

@interface AsynImageCache ()

@property (nonatomic, strong) NSCache *imageDataCache;

@end

@implementation AsynImageCache

#pragma mark - Singleton

+ (instancetype)shared
{
    static AsynImageCache *manager = nil;
    static dispatch_once_t oncePredicate;
    if (!manager) {
        dispatch_once(&oncePredicate, ^{
            manager = [[AsynImageCache alloc] init];
            manager.imageDataCache = [[NSCache alloc] init];
        });
    }
    return manager;
}

#pragma mark - Cache Syetem

/*!
 *  @author Tongtong Xu, 15-04-03 23:04:39
 *
 *  @brief  将图片缓存到Cache中
 *
 *  @param image 图片
 *  @param url   图片地址
 */

+ (void)cacheImage:(UIImage *)image imageURL:(NSString *)url
{
    if (image && url) {
        [[AsynImageCache shared].imageDataCache setObject:image forKey:[self imageNameWithURL:url]];
    }
}

/*!
 *  @author Tongtong Xu, 15-04-03 23:04:10
 *
 *  @brief  根据图片地址从缓存中读取图片
 *
 *  @param key 图片地址
 *
 *  @return 图片对象
 */

+ (UIImage *)imageCachedWithKey:(NSString *)key
{
    NSCache *cache = [AsynImageCache shared].imageDataCache;
    return [cache objectForKey:[self imageNameWithURL:key]];
}

#pragma mark - Public

+ (UIImage *)cachedImageWithURL:(NSString *)imageURL
{
    id object = [self imageCachedWithKey:imageURL];
    if (object) {
        NSLog(@"%@,load from memory",imageURL);
        return object;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self imageFilepathWithURL:imageURL]]) {
        NSData *data = [NSData dataWithContentsOfFile:[self imageFilepathWithURL:imageURL]];
        UIImage *image = [self cacheImageWithData:data imageURL:imageURL];
        NSLog(@"%@,load from disk,then save to memory",imageURL);
        return image;
    }
    
    NSLog(@"%@,need download form server",imageURL);
    return nil;
}

+ (UIImage *)cacheImageWithData:(NSData *)imageData imageURL:(NSString *)imageURL
{
    UIImage *image = [UIImage imageWithData:imageData];
    UIImage *decodedImage = [self decoderImage:image];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self imageFilepathWithURL:imageURL]]) {
        NSLog(@"%@,save to disk",imageURL);
        [imageData writeToFile:[self imageFilepathWithURL:imageURL] atomically:YES];
    }
    image = nil;
    imageData = nil;
    [self cacheImage:decodedImage imageURL:imageURL];
    return decodedImage;
}

+ (void)clearMemoryCache
{
    NSCache *cache = [AsynImageCache shared].imageDataCache;
    [cache removeAllObjects];
}

+ (void)clearDiskCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[self rootCacheFilepath] error:nil];
}

#pragma mark - Private

+ (UIImage *)decoderImage:(UIImage *)image
{
    return [image thumbnailImage:80 interpolationQuality:kCGInterpolationLow];
}

/*!
 *  @author Tongtong Xu, 15-04-03 20:04:27
 *
 *  @brief  将图片地址编码
 *
 *  @param url 图片的URL
 *
 *  @return 编码后的图片URL
 */

+ (NSString *)imageNameWithURL:(NSString *)url
{
    return [self cachedFileNameForKey:url];
}

/*!
 *  @author Tongtong Xu, 15-04-03 20:04:23
 *
 *  @brief  将图片URL编码后生成缓存路径
 *
 *  @param url 图片地址
 *
 *  @return 图片的缓存路径
 */

+ (NSString *)imageFilepathWithURL:(NSString *)url
{
    return [[self rootCacheFilepath] stringByAppendingPathComponent:[self imageNameWithURL:url]];
}

/*!
 *  @author Tongtong Xu, 15-04-03 20:04:40
 *
 *  @brief  存放图片缓存的目录,若不存在则创建
 *
 *  @return 缓存文件的根目录
 */

+ (NSString *)rootCacheFilepath
{
    NSString *rootCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/AsynImage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return rootCachePath;
}

/*!
 *  @author Tongtong Xu, 15-04-03 20:04:20
 *
 *  @brief  将图片URL编码
 *
 *  @param key URL地址
 *
 *  @return 编码后的URL，唯一
 */

+ (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

@end

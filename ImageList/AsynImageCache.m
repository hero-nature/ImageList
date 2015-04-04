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

+ (void)cacheImage:(UIImage *)image key:(NSString *)key
{
    if (image && key) {
        [[AsynImageCache shared].imageDataCache setObject:image forKey:key];
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
    return [[AsynImageCache shared].imageDataCache objectForKey:key];
}

#pragma mark - Public

+ (UIImage *)cachedImageWithURL:(NSString *)imageURL decodeType:(AsynImageDecodeType)type
{
    NSString *key = [self cacheKeyWithImageURL:imageURL decodeType:type];
    
    id object = [self imageCachedWithKey:key];
    if (object) {
        NSLog(@"%@_%@,load from memory",imageURL,type == AsynImageDecodeTypeThumb ? @"thumb" : @"normal");
        return object;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self imageFilepathWithURL:imageURL]]) {
        NSData *data = [NSData dataWithContentsOfFile:[self imageFilepathWithURL:imageURL]];
        UIImage *image = [self cacheImageWithData:data imageURL:imageURL decodeType:type];
        NSLog(@"%@_%@,load from disk,then save to memory",imageURL,type == AsynImageDecodeTypeThumb ? @"thumb" : @"normal");
        return image;
    }
    
    NSLog(@"%@_%@,need download form server",imageURL,type == AsynImageDecodeTypeThumb ? @"thumb" : @"normal");
    return nil;
}

+ (UIImage *)cacheImageWithData:(NSData *)imageData imageURL:(NSString *)imageURL decodeType:(AsynImageDecodeType)type
{
    UIImage *image = [UIImage imageWithData:imageData];
    UIImage *decodedImage = [self decoderImage:image decodeType:type];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self imageFilepathWithURL:imageURL]]) {
        NSLog(@"%@,save to disk",imageURL);
        [imageData writeToFile:[self imageFilepathWithURL:imageURL] atomically:YES];
    }
    image = nil;
    imageData = nil;
    [self cacheImage:decodedImage key:[self cacheKeyWithImageURL:imageURL decodeType:type]];
    return decodedImage;
}

+ (void)clearMemoryCache
{
    [[AsynImageCache shared].imageDataCache removeAllObjects];
}

+ (void)clearDiskCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[self rootCacheFilepath] error:nil];
}

#pragma mark - Private

/*!
 *  @author Tongtong Xu, 15-04-04 12:04:26
 *
 *  @brief  Decode Image
 *
 *  @param image
 *
 *  @return
 */
+ (UIImage *)decoderImage:(UIImage *)image decodeType:(AsynImageDecodeType)type
{
    UIImage *decodedImage;
    switch (type) {
        case AsynImageDecodeTypeThumb:
            decodedImage = [image thumbnailImage:80 interpolationQuality:kCGInterpolationLow];
            break;
        case AsynImageDecodeTypeNormal:
            decodedImage = [image resizedImage:image.size interpolationQuality:kCGInterpolationDefault];
            break;
    }
    return decodedImage;
}

+ (NSString *)cacheKeyWithImageURL:(NSString *)imageURL decodeType:(AsynImageDecodeType)type
{
    NSString *key;
    switch (type) {
        case AsynImageDecodeTypeNormal:
            key = [[self imageNameWithURL:imageURL] stringByAppendingString:@"_normal"];
            break;
        case AsynImageDecodeTypeThumb:
            key = [[self imageNameWithURL:imageURL] stringByAppendingString:@"_thumb"];
            break;
    }
    return key;
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

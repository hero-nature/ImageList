//
//  AsynImageCache.h
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AsynImageCache : NSObject
/*!
 *  @author Tongtong Xu, 15-04-03 23:04:13
 *
 *  @brief  从缓存中读取图片
 *
 *  @param imageURL 图片地址
 *
 *  @return 图片对象，可能为nil
 */
+ (UIImage *)cachedImageWithURL:(NSString *)imageURL;
/*!
 *  @author Tongtong Xu, 15-04-03 23:04:47
 *
 *  @brief  图片数据下载完成后对图片进行解码
 *
 *  @param imageData 图片数据
 *  @param imageURL  图片地址，用于标识图片
 *
 *  @return 解码后的图片
 */
+ (UIImage *)cacheImageWithData:(NSData *)imageData imageURL:(NSString *)imageURL;
/*!
 *  @author Tongtong Xu, 15-04-03 23:04:35
 *
 *  @brief  清理图片内存
 */
+ (void)clearMemoryCache;
/*!
 *  @author Tongtong Xu, 15-04-03 23:04:50
 *
 *  @brief  清空磁盘缓存
 */
+ (void)clearDiskCache;
@end

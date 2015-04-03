//
//  NetEngine.h
//  DIDITest
//
//  Created by unisedu on 15/4/2.
//  Copyright (c) 2015年 unisedu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NetEngine : NSObject

//Post请求
+ (void)postWithParameters:(NSDictionary *)params
                     block:(void (^)(NSDictionary *resultDic, NSError *error))block;
@end

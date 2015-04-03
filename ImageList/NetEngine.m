//
//  NetEngine.m
//  DIDITest
//
//  Created by unisedu on 15/4/2.
//  Copyright (c) 2015年 unisedu. All rights reserved.
//

#import "NetEngine.h"

#define BASEURL @"http://test.tainiu.cn/audition/imglist"

@implementation NetEngine

+ (void)postWithParameters:(NSDictionary *)params
                     block:(void (^)(NSDictionary *resultDic, NSError *error))block
{
    NSURL *url = [NSURL URLWithString:BASEURL];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:30.0];
    run_async_background({
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            run_async_main({
                if (block) { block(nil, error); }
            })
        }else{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                run_async_main({
                    if (block) { block(nil, error); }
                })
            }else{
                run_async_main({
                    if (block) { block(dic, nil); }
                })
            }
        }
    })
}
@end

//
//  ImageDetailViewController.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/4.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "AsynImageCache.h"

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [AsynImageCache clearMemoryCache];
}

@end

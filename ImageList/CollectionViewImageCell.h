//
//  CollectionViewImageCell.h
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewImageCell : UICollectionViewCell

@property (nonatomic, strong) id data;

//Subview must override
- (void)configCell;

+ (NSString *)reuseIdentifier;

@end

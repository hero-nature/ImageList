//
//  CollectionViewImageCell.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "CollectionViewImageCell.h"
#import "AsynImageView.h"

@interface CollectionViewImageCell ()
@property (weak, nonatomic) IBOutlet AsynImageView *imageView;
@end

@implementation CollectionViewImageCell

- (void)setData:(id)data
{
    _data = data;
    [self configCell];
}

- (void)configCell
{
    if (self.data) {
        [self.imageView setImageURL:self.data placeholderImage:[UIImage imageNamed:@"defaultImage"]];
    }
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end

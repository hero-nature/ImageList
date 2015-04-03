//
//  ViewController.m
//  ImageList
//
//  Created by Tongtong Xu on 15/4/3.
//  Copyright (c) 2015年 xxx Innovation Co. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "NetEngine.h"
#import "CollectionViewImageCell.h"
#import "AsynImageCache.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (weak, nonatomic) IBOutlet UIView *progressHUD;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *errorMessageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic) UInt64 timeinterval;
@property (nonatomic) BOOL isLoadingData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (UInt64)timeinterval
{
    if (!_timeinterval) {
        _timeinterval = [[NSDate date] timeIntervalSince1970];
    }
    return _timeinterval;
}

-(void)loadData
{
    if (_isLoadingData) {
        return;
    }

    self.isLoadingData = YES;
    [NetEngine postWithParameters:@{@"from_id" : @(self.timeinterval)} block:^(NSDictionary *resultDic, NSError *error) {
        self.isLoadingData = NO;
        if(error){
            [self showError:error errorMessage:error.domain];
        }else{
            if ([[resultDic objectForKey:@"errno"] intValue]) {
                [self showError:[NSError errorWithDomain:@"请求失败" code:200 userInfo:nil] errorMessage:[resultDic objectForKey:@"errmsg"]];
            }else{
                _timeinterval = [[resultDic objectForKey:@"next_id"] unsignedLongLongValue];
                NSArray *array = [resultDic objectForKey:@"pics"];
                if (_dataSource) {
                    _dataSource = [_dataSource arrayByAddingObjectsFromArray:array];
                }else{
                    _dataSource = array;
                }
                [self.collection reloadData];
            }
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewImageCell reuseIdentifier] forIndexPath:indexPath];
    cell.data = [[_dataSource objectAtIndex:indexPath.row] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *footerLoadMoreView =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                       withReuseIdentifier:@"CollectionViewLoadMoreView"
                                              forIndexPath:indexPath];
    return footerLoadMoreView;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) - scrollView.contentSize.height > -20) {
        [self loadData];
    }
}

#pragma mark - HUD

- (void)showProgressHUD
{
    self.progressHUD.hidden = NO;
    [self.view bringSubviewToFront:self.progressHUD];
    [self.activityIndicator startAnimating];
}

- (void)hideProgressHUD
{
    [UIView animateWithDuration:0.5 animations:^{
        self.progressHUD.alpha = 0;
    }completion:^(BOOL finished) {
        self.progressHUD.hidden = YES;
        self.progressHUD.alpha = 1;
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - Error Message

- (void)showError:(NSError *)error errorMessage:(NSString *)message
{
    self.errorMessageView.hidden = NO;
    [self.view bringSubviewToFront:self.errorMessageView];
    self.errorLabel.text = message.length ? message : error.domain;
    [UIView animateWithDuration:0.5 animations:^{
        self.errorMessageView.alpha = 0;
    }completion:^(BOOL finished) {
        self.errorMessageView.hidden = YES;
        self.errorMessageView.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [AsynImageCache clearMemoryCache];
}

@end

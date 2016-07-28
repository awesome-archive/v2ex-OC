//
//  WTHotNodeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/21.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//  热门节点

#import "WTHotNodeViewController.h"
#import "WTNodeViewModel.h"
#import "WTHotNodeCell.h"
#import "WTHotNodeReusableView.h"
#import "WTTopicViewController.h"
#import "WTNodeTopicViewController.h"

static NSString *const ID = @"topicCell";

@interface WTHotNodeViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) WTNodeViewModel *nodeVM;

/** 热点节点的数组 */
@property (nonatomic, strong) NSMutableArray<WTNodeViewModel *> *nodeVMs;

@end

@implementation WTHotNodeViewController

static NSString * const reuseIdentifier = @"reuseIdentifier";

static NSString * const headerViewReuseIdentifier = @"headerViewReuseIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置View
    [self setupView];
    
    // 设置数据
    [self setupData];
}

/**
 *   设置View
 */
- (void)setupView
{
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib: [UINib nibWithNibName: @"WTHotNodeCell" bundle: nil] forCellWithReuseIdentifier: reuseIdentifier];

    [self.collectionView registerNib: [UINib nibWithNibName: @"WTHotNodeReusableView" bundle: nil] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: headerViewReuseIdentifier];
}

/**
 *  设置数据
 */
- (void)setupData
{
    self.nodeVM = [WTNodeViewModel new];
    
    __weak typeof(self) weakSelf = self;
    [self.nodeVM getNodeItemsWithSuccess:^(NSMutableArray<WTNodeViewModel *> *nodeVMs) {
    
        weakSelf.nodeVMs = nodeVMs;
        
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return self.nodeVMs.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.nodeVMs[section].nodeItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WTHotNodeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: reuseIdentifier forIndexPath: indexPath];
    
    cell.nodeItem = self.nodeVMs[indexPath.section].nodeItems[indexPath.row];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    WTHotNodeReusableView *hotNodeRView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: headerViewReuseIdentifier forIndexPath: indexPath];

    hotNodeRView.title = self.nodeVMs[indexPath.section].title;
    
    return hotNodeRView;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WTNodeItem *nodeItem = self.nodeVMs[indexPath.section].nodeItems[indexPath.row];
    WTNodeTopicViewController *nodeTopicVC = [WTNodeTopicViewController new];
    nodeTopicVC.nodeItem = nodeItem;
    [self.navigationController pushViewController: nodeTopicVC animated: YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.nodeVMs[indexPath.section].nodeItems[indexPath.row].width, 25);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.bounds.size.width, 35);
}

@end

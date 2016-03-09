//
//  WTNodeViewController.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/30.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTNodeViewController.h"
#import "WTNodeCell.h"
static NSString * const ID = @"nodeCell";

@interface WTNodeViewController () <UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView    *collectionView;
@end

@implementation WTNodeViewController

- (instancetype)init
{
    return [[UIStoryboard storyboardWithName: NSStringFromClass([WTNodeViewController class]) bundle: nil] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 注册cell
    [self.collectionView registerClass: [WTNodeCell class] forCellWithReuseIdentifier: ID];
    
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 25;
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 4;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WTNodeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: ID forIndexPath: indexPath];
    WTLog(@"index:%ld", indexPath.row)
    cell.backgroundColor = indexPath.item % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
    return cell;
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (_collectionView == nil)
    {
        // 1、创建布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 20;
        layout.minimumLineSpacing = 20;
        layout.itemSize = CGSizeMake(68, 16);
        
        // 2、创建collectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame: self.view.bounds collectionViewLayout: layout];
        [self.view addSubview: collectionView];
        _collectionView = collectionView;
        
        // 3、设置属性
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor greenColor];
    }
    return _collectionView;
}

@end

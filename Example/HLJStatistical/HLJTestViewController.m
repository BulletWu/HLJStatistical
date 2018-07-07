//
//  HLJTestViewController.m
//  HLJStatisticalDemo
//
//  Created by 吴晓辉 on 2018/6/27.
//  Copyright © 2018年 婚礼纪. All rights reserved.
//

#import "HLJTestViewController.h"
#import "Masonry.h"
#import "UIView+Statistical.h"

@interface HLJTestViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic ,strong) UICollectionView *collectionView;

@end

@implementation HLJTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.frame.size.width - 10)/2.0, 100.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    [cell hlj_setTrackTag:@"collectionView" position:indexPath.row];
    return cell;
}


#pragma mark - getters and setters
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 10.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];

        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


@end

//
//  UIView+Statistical.h
//  HLJStatisticalDemo
//
//  Created by 吴晓辉 on 2018/6/27.
//  Copyright © 2018年 婚礼纪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HLJViewTrackModel;

@interface UIView (Statistical)

@property (nonatomic ,assign) BOOL hlj_viewVisible;
@property (nonatomic ,strong ,readonly) HLJViewTrackModel *hlj_trackModel;

- (void)hlj_setTrackTag:(NSString *)trackTag position:(NSInteger)position;
- (void)hlj_setTrackTag:(NSString *)trackTag position:(NSInteger)position trackData:(NSDictionary *)trackData;
- (void)hlj_setTrackTag:(NSString *)trackTag;

@end

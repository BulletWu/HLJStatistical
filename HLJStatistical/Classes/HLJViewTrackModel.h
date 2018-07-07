//
//  HLJViewTrackModel.h
//  HLJStatistical_Example
//
//  Created by 吴晓辉 on 2018/7/4.
//  Copyright © 2018年 吴晓辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLJViewTrackModel : NSObject

- (instancetype)initWithTag:(NSString *)tag;

@property (nonatomic ,copy) NSString *tag;
@property (nonatomic ,assign) NSInteger position;
@property (nonatomic ,copy) NSDictionary *data;

@end

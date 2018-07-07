//
//  HLJViewTrackModel.m
//  HLJStatistical_Example
//
//  Created by 吴晓辉 on 2018/7/4.
//  Copyright © 2018年 吴晓辉. All rights reserved.
//

#import "HLJViewTrackModel.h"

@implementation HLJViewTrackModel

- (instancetype)initWithTag:(NSString *)tag {
    if (!tag) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.tag = tag;
    }
    return self;
}

- (BOOL)isEqual:(HLJViewTrackModel *)object {
    if (!object) {
        return NO;
    }
    return  [self.tag isEqual:object.tag] && self.position == object.position && [self.data isEqualToDictionary:object.data];
}

@end

//
//  UIView+Statistical.m
//  HLJStatisticalDemo
//
//  Created by 吴晓辉 on 2018/6/27.
//  Copyright © 2018年 婚礼纪. All rights reserved.
//

#import "UIView+Statistical.h"
#import <objc/runtime.h>
#import "HLJViewTrackModel.h"

@interface UIView ()

@property (nonatomic ,strong,readwrite) HLJViewTrackModel *hlj_trackModel;

@end

@implementation UIView (Statistical)

+ (void)exChanageMethodSystemSel:(SEL)systemSel swizzSel:(SEL)swizzSel{
    //两个方法的Method
    Method systemMethod = class_getInstanceMethod([self class], systemSel);
    Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
    //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
    BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
    if (isAdd) {
        //如果成功，说明类中不存在这个方法的实现
        //将被交换方法的实现替换到这个并不存在的实现
        class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        //否则，交换两个方法的实现
        method_exchangeImplementations(systemMethod, swizzMethod);
    }
}

//影响一个view是否可见的因素
//1.frame的改变
//2.bounds的改变
//3.view或者父试图是否加载到Window上
//4.Hidden的改变
//5.Alpha的改变
//

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL setFrameSel = @selector(setFrame:);
        SEL swizzhSetFrameSel = @selector(hlj_setFrame:);
        [[self class] exChanageMethodSystemSel:setFrameSel swizzSel:swizzhSetFrameSel];
        
        SEL setBoundsSel = @selector(setBounds:);
        SEL swizzhSetBoundsSel = @selector(hlj_setBounds:);
        [[self class] exChanageMethodSystemSel:setBoundsSel swizzSel:swizzhSetBoundsSel];
        
        SEL didMoveToWindowSel = @selector(didMoveToWindow);
        SEL swizzhdidMoveToWindowSel = @selector(hlj_didMoveToWindow);
        [[self class] exChanageMethodSystemSel:didMoveToWindowSel swizzSel:swizzhdidMoveToWindowSel];
        
        SEL setHiddenSel = @selector(setHidden:);
        SEL swizzhSetHiddenSel = @selector(hlj_setHidden:);
        [[self class] exChanageMethodSystemSel:setHiddenSel swizzSel:swizzhSetHiddenSel];
        
        SEL setAlphaSel = @selector(setAlpha:);
        SEL swizzhSetAlphaSel = @selector(hlj_setAlpha:);
        [[self class] exChanageMethodSystemSel:setAlphaSel swizzSel:swizzhSetAlphaSel];
    });
}

- (void)hlj_didMoveToWindow {
    [self hlj_didMoveToWindow];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hlj_calculateViewVisible) object:nil];
    [self performSelector:@selector(hlj_updateViewVisible) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
}

- (void)hlj_setFrame:(CGRect)frame {
    [self hlj_setFrame:frame];
    [self hlj_updateViewVisible];
}

- (void)hlj_setBounds:(CGRect)bounds {
    [self hlj_setBounds:bounds];
    [self hlj_updateViewVisible];
}

- (void)hlj_setHidden:(BOOL)hidden {
    [self hlj_setHidden:hidden];
    [self hlj_updateViewVisible];
}

- (void)hlj_setAlpha:(CGFloat)alpha {
    [self hlj_setAlpha:alpha];
    [self hlj_updateViewVisible];
}

#pragma mark - public methods
- (void)hlj_setTrackTag:(NSString *)trackTag {
    [self hlj_setTrackTag:trackTag position:0 trackData:nil];
}

- (void)hlj_setTrackTag:(NSString *)trackTag position:(NSInteger)position {
    [self hlj_setTrackTag:trackTag position:position trackData:nil];
}

- (void)hlj_setTrackTag:(NSString *)trackTag position:(NSInteger)position trackData:(NSDictionary *)trackData {
    HLJViewTrackModel *trackModel = [[HLJViewTrackModel alloc] initWithTag:trackTag];
    trackModel.position = position;
    trackModel.data = trackData;
    if ([self.hlj_trackModel isEqual:trackModel]) {
        return;
    }
    self.hlj_trackModel = trackModel;
    if (!trackModel) {
        return;
    }
    self.hlj_viewVisible = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hlj_calculateViewVisible) object:nil];
    [self performSelector:@selector(hlj_calculateViewVisible) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
}

#pragma mark - private methods
- (void)hlj_updateViewVisible {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hlj_calculateViewVisible) object:nil];
    [self performSelector:@selector(hlj_calculateViewVisible) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
    for (UIView *view in self.subviews) {
        [view hlj_updateViewVisible];
    }
}

- (void)hlj_calculateViewVisible {
    self.hlj_viewVisible = [self hlj_isDisplayedInScreen];
}

- (BOOL)hlj_isDisplayedInScreen {
    if (self == nil) {
        return NO;
    }
    if (self.hidden) {
        return NO;
    }
    if (self.alpha <= 0.1) {
        return NO;
    }
    if (!self.window) {
        return NO;
    }
    if (self.superview && ![self.superview.nextResponder isKindOfClass:[UIViewController class]] && !self.superview.hlj_viewVisible) {
        return NO;
    }
    //iOS11 以下 特殊处理 UITableViewWrapperView 需要使用的supview
    //UITableviewWrapperview 的大小为tableView 在屏幕中出现第一个完整的屏幕大小的视图
    //并且会因为contentOffset的改变而改变，所以UITableviewWrapperview会滑出屏幕，这样因为self.superview.hlj_viewVisible 这个条件导致 他下面的子试图都被判定为不可见，因此将cell的父试图为UITableViewWrapperView的时候，使用tableView 计算
    UIView *view = self;
    if ([NSStringFromClass([self class]) isEqualToString:@"UITableViewWrapperView"]) {
        view = self.superview;
    }
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [view convertRect:view.bounds toView:window];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }
    return YES;
}

- (void)hlj_viewStatistical {
    NSLog(@"hlj_trackTag:%@,position:%zd",self.hlj_trackModel.tag,self.hlj_trackModel.position);
}

- (void)setHlj_viewVisible:(BOOL)hlj_viewVisible {
    if (!self.hlj_viewVisible && hlj_viewVisible) {
        if (self.hlj_trackModel) {
            [self hlj_viewStatistical];
        }
    }
    objc_setAssociatedObject(self, @selector(hlj_viewVisible), @(hlj_viewVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hlj_viewVisible {
    return [objc_getAssociatedObject(self, @selector(hlj_viewVisible)) boolValue];
}

- (HLJViewTrackModel *)hlj_trackModel {
    return objc_getAssociatedObject(self, @selector(hlj_trackModel));
}

- (void)setHlj_trackModel:(HLJViewTrackModel *)hlj_trackModel {
    objc_setAssociatedObject(self, @selector(hlj_trackModel), hlj_trackModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

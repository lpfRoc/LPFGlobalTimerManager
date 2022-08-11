//
//  LPFGlobalTimerManager.h
//
//  Created by lipengfei on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LPFGlobalTimerManagerDelegate <NSObject>

- (void)updateGlobalTimerByTimeInterval:(NSTimeInterval)timeInterval;

@end

@interface LPFGlobalTimerManager : NSObject

+ (instancetype)shared;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

///全局定时器添加/移除代理
- (void)addGlobalTimerDelegate:(id<LPFGlobalTimerManagerDelegate>)delegate;

- (void)removeGlobalTimerDelegate:(id<LPFGlobalTimerManagerDelegate>)delegate;
@end


NS_ASSUME_NONNULL_END

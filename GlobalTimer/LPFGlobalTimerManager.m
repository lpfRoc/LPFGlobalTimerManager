//
//  LPFGlobalTimerManager.m
//
//  Created by lipengfei on 2021/7/5.
//

#import "LPFGlobalTimerManager.h"
#import <pthread.h>
#import "YPPLog.h"
@interface LPFGlobalTimerManager () {
    pthread_mutex_t _lock;
    NSTimeInterval _interval;
}
///全局定时器事件代理数组
@property (nonatomic, strong) NSHashTable *delegateArray;
@property (nonatomic, strong) dispatch_source_t globalTimer;
///定时器是否正在运行
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation LPFGlobalTimerManager

+ (instancetype)shared {
    static LPFGlobalTimerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _delegateArray = [NSHashTable weakObjectsHashTable];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)updateTimerAction {
    //YPPLogInfo(@"%@",self.delegateArray);
    if (self.delegateArray.count == 0) {
        return;
    }
    NSArray *copyArr = self.delegateArray.copy;
    for (id <LPFGlobalTimerManagerDelegate>detegate in copyArr) {
        if ([detegate respondsToSelector:@selector(updateGlobalTimerByTimeInterval:)]) {
            [detegate updateGlobalTimerByTimeInterval:_interval];
        }
    }
}

- (void)resumeTimer {
    if (self.isRunning) {
        return;
    }
    dispatch_resume(self.globalTimer);
    self.isRunning = YES;
}

- (void)suspendTiemr {
    if (!self.isRunning) {
        return;
    }
    dispatch_suspend(self.globalTimer);
    self.isRunning = NO;
}

- (void)addGlobalTimerDelegate:(id<LPFGlobalTimerManagerDelegate>)delegate {
    if (delegate) {
        pthread_mutex_lock(&_lock);
        if (![self.delegateArray containsObject:delegate]) {
            [self.delegateArray addObject:delegate];
        }
        if (self.delegateArray.count) {
            [self resumeTimer];
        }
        pthread_mutex_unlock(&_lock);
    }
}

- (void)removeGlobalTimerDelegate:(id<LPFGlobalTimerManagerDelegate>)delegate {
    if (delegate) {
        pthread_mutex_lock(&_lock);
        if ([self.delegateArray containsObject:delegate]) {
            [self.delegateArray removeObject:delegate];
        }
        if (self.delegateArray.count == 0) {
            [self suspendTiemr];
        }
        pthread_mutex_unlock(&_lock);
    }
}

- (dispatch_source_t)globalTimer {
    if (!_globalTimer) {
        _globalTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        _interval = 1;
        dispatch_source_set_timer(_globalTimer, DISPATCH_TIME_NOW, _interval * NSEC_PER_SEC, 0);
        __weak typeof(self) wself = self;
        dispatch_source_set_event_handler(_globalTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(wself) sself = wself;
                [sself updateTimerAction];
            });
        });
    }
    return _globalTimer;
}
@end

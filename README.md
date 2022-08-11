# LPFGlobalTimerManager
一个全局定时器
LPFGlobalTimerManager全局定时器单例，对外暴露add/remove定时任务接口，及定时任务回调协议。业务方只需在用到的地方add定时任务，不需时remove（默认会在类dealloc时自行回收，但全局timer仍在run，及时调用remove会suspend全局timer）并实现协议即可。全局定时任务默认最小时间间隔1s，针对时间间隔不为1s的场景，需业务方特殊处理。
主要接口：

``` bash
@protocol LPFGlobalTimerManagerDelegate <NSObject>
- (void)updateGlobalTimerByTimeInterval:(NSTimeInterval)timeInterval;
@end

///全局定时器添加代理
- (void)addGlobalTimerDelegate:(id<LPFGlobalTimerManagerDelegate>)delegate;
///全局定时器移除代理
- (void)removeGlobalTimerDelegate:(id<LPFGlobalTimerManagerDelegate>)delegate;

```

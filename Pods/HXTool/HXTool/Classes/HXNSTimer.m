//
//  HXNSTimer.m
//  HXTool
//
//  Created by 海啸 on 2017/11/18.
//

#import "HXNSTimer.h"

/*!brief ignore clang warning
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
@implementation NSTimer(HXTool)

+ (instancetype )hx_scheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *))block {
//    NSTimer有个比较恶心的特性，它会持有它的target。比如在一个controller中使用了timer，并且timer的target设置为该controller本身，那么想在controller的dealloc中fire掉timer是做不到的，必须要在其他的地方fire。这会让编码很难受。具体参考《Effective Objective C》的最后一条。 BlocksKit解除这种恶心，其方式是把timer的target设置为timer 的class对象。把要执行的block保存在timer的userInfo中执行。因为timer 的class对象一直存在，所以是否被持有其实无所谓。
    NSTimer  *timer = [self hx_timerWithTimeInterval:seconds repeats:repeats block:block];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    return timer;
}

+ (instancetype )hx_timerWithTimeInterval:(NSTimeInterval)inSeconds repeats:(BOOL)repeats block:(void (^)(NSTimer *))block {
    NSParameterAssert(block != nil);
    CFAbsoluteTime seconds = fmax(inSeconds, 0.0001);
    CFAbsoluteTime interval = repeats ? seconds : 0;
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent() + seconds;
    return (__bridge_transfer NSTimer *)CFRunLoopTimerCreateWithHandler(NULL, fireDate, interval, 0, 0, (void(^)(CFRunLoopTimerRef))block);
}

@end

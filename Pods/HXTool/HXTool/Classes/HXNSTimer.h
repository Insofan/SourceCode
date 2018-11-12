//
//  HXNSTimer.h
//  HXTool
//
//  Created by 海啸 on 2017/11/18.
//

#import <UIKit/UIKit.h>

@interface NSTimer (HXTool)

/**
 Create a new NSTimer object,schedules it on the current loop, and returns it.
 @param seconds NSTimerInterval The seconds before do block.
 @param repeats Bool Repeats or not
 @param block Block Block with method
 @return NSTimer A new NSTimer object.
 */
+ (instancetype)hx_scheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

/** Creates and returns a new @c NSTimer object using the specified handler.
 *
 * You must add the new timer to a run loop, using @c addTimer:forMode:. Upon
 * firing, the timer fires the block. If the timer is configured to repeat,
 * there is no need to subsequently re-add the timer to the run loop.
 *
 * @param seconds For a repeating timer, the seconds between firings of the
 * timer. If seconds is less than or equal to @c 0.0, @c 0.1 is used instead.
 * @param repeats If @c YES, the timer will repeatedly reschedule itself until
 * invalidated. If @c NO, the timer will be invalidated after it fires.
 * @param block The code unit to execute when the timer fires.
 * @return A new @c NSTimer object, configured according to the specified parameters.
 */

+ (instancetype)hx_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end

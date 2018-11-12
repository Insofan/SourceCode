//
//  HXNSArray.m
//  HXTool
//
//  Created by 海啸 on 2017/11/10.
//

#import "HXNSArray.h"

@implementation NSArray(HXTool)

- (void)hx_each:(void (^)(id obj))block
{
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

@end

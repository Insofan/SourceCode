//
//  HXDictionary.m
//  HXTool
//
//  Created by 海啸 on 2017/11/10.
//

#import "HXNSDictionary.h"

@implementation NSDictionary (HXTool)

- (void)hx_each:(void (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
@end

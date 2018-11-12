//
//  HXNSArray.h
//  HXTool
//
//  Created by 海啸 on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "HXMacros.h"



@interface GENERICS(NSArray, ObjectType) (HXTool)

/**
 Enumerate objects of array
 @param Block Object
 */
- (void)hx_each:(void (^)(ObjectType obj))block;

@end

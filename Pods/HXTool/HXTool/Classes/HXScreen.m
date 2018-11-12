//
//  HXScreenTool.m
//  HXTool
//
//  Created by 海啸 on 2017/3/20.
//  Copyright © 2017年 Insofan. All rights reserved.
//

#import "HXScreen.h"

@implementation UIScreen(HXTool)
+ (CGFloat )hx_screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat )hx_screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGRect )hx_screenBounds {
    return [[UIScreen mainScreen] bounds];
}

+ (CGFloat )hx_scale {
    return [UIScreen mainScreen].scale;
}

+ (CGFloat )hx_appFrameHeight {
    return [[UIScreen mainScreen] applicationFrame].size.height;
}

+ (CGFloat )hx_appFrameWidth {
    return [[UIScreen mainScreen] applicationFrame].size.width;
}


@end

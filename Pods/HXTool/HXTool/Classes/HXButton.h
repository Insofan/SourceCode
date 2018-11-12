//
//  HXButtonTool.h
//  HXTool
//
//  Created by 海啸 on 2017/2/28.
//  Copyright © 2017年 Insofan. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIButton(HXTool)

/**
 Easy way to set up UIButton

 @param title NSString Button title
 @param fontSize CGFloat Button font size
 @param normalColor UIColor Button normal color
 @param selectedColor UIColor Button selected color
 @return UIButton
 */
+ (instancetype)hx_buttonWithTitle:(NSString *)title fontSize:(CGFloat )fontSize normalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor;
@end

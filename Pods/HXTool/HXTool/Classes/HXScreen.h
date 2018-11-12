//
//  HXScreenTool.h
//  HXTool
//
//  Created by 海啸 on 2017/3/20.
//  Copyright © 2017年 Insofan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScreen(HXTool)

/**
 Get current screen width
 @return CGFloat Screen width
 */
+ (CGFloat )hx_screenWidth;

/**
 Get current screen height
 @return CGFloat Screen height
 */
+ (CGFloat )hx_screenHeight;

/**
 Get current screen screen bounds

 @return CGRect Screen bounds
 */
+ (CGRect )hx_screenBounds;

/**
 Get current screen scale

 @return CGFloat Screen scale
 */
+ (CGFloat )hx_scale;

/**
 Frame of application screen area height in points (i.e.entire screen minus status bar if visible)

 @return CGFloat App frame height
 */
+ (CGFloat )hx_appFrameHeight;

/**
 Frame of application screen area height in points (i.e.entire screen minus status bar if visible)

 @return CGFloat App frame width
 */
+ (CGFloat )hx_appFrameWidth;

@end

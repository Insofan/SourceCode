//
//  HXTool.h
//  Pods
//
//  Created by 海啸 on 2017/2/27.
//
//
#import <UIKit/UIKit.h>
@interface UIColor(HXTool)
/**
 Easy way to get Hex color
 
 @param string Hex color string
 @return UIColor
 */
+ (UIColor *)hx_colorWithHexString:(NSString *)string;


/**
 Easy way to get rgb color

 @param red UIColor Red color number
 @param green UIColor Green color number
 @param blue UIColor Blue color number
 @return UIColor
 */
+ (UIColor *)hx_colorWithRGBNumber:(NSUInteger )red green:(NSUInteger )green blue:(NSUInteger )blue;

/**
 Easy way to get rgb color with alpha

 @param red UIColor Red color number
 @param green UIColor Green color number
 @param blue UIColor Blue color number
 @param alpha NSUInteger Color alpha number
 @return UIColor
 */
+ (UIColor *)hx_colorWithRGBNumber:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(NSUInteger)alpha;

/**
 Easy way to get a random color

 @return UIColor
 */
+ (UIColor *)hx_randomColor;
@end

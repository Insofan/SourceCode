//
//  HXMacros.h
//  HXTool
//
//  Created by 海啸 on 2017/11/5.
//

#ifndef HXMacros_h
#define HXMacros_h

// 当前版本
#define FSystemVersion          ([[[UIDevice currentDevice] systemVersion] floatValue])
#define DSystemVersion          ([[[UIDevice currentDevice] systemVersion] doubleValue])
#define SSystemVersion          ([[UIDevice currentDevice] systemVersion])

// 是否IOS7
#define IsIOS7                  ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
// 是否IOS6
#define IsIOS6                  ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0)
//
#define IsIOS8                  ([[[UIDevice currentDevice]systemVersion]floatValue] >=8.0)

//App版本号
#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//obj范型，计算obj类型


/**
 判断objc是否有泛型

 @param objc_generics 如果有泛型
 @return 
 */
#if __has_feature(objc_generics)
#   define GENERICS(class, ...)      class<__VA_ARGS__>
#   define GENERICS_TYPE(type)       type
#else
#   define GENERICS(class, ...)      class
#   define GENERICS_TYPE(type)       id
#endif

#endif /* HXMacros_h */

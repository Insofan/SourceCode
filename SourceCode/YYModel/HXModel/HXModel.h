//
//  HXModel.h
//  SourceCode
//
//  Created by Insomnia on 2018/11/14.
//  Copyright © 2018年 Insomnia. All rights reserved.
//

#import <Foundation/Foundation.h>

//使用了一个 include 判断宏, 这里主要是两种导入方式, <> 与"", <>从编译器指定位置开始搜索, ""从项目位置开始
#if __has_include(<HXModel/HModel.h>)
//iOS中, FOUNDATION_EXPORT 和#define 作用是一样的，使用第一种在检索字符串的时候可以用 ==  #define 需要使用isEqualToString 在效率上前者由于是基于地址的判断 速度会更快一些
FOUNDATION_EXPORT double HXModelVersionNumber;
FOUNDATION_EXPORT const unsigned char HXModelVersionString[];

#import <HXModel/NSObject+HXModel.h>
#import <HXModel/HXClassInfo.h>

#else
#import "NSObject+HXModel.h"
#import "HXClassInfo.h"
#endif



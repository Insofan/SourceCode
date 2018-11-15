//
// Created by Insomnia on 2018/11/14.
// Copyright (c) 2018 Insomnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Type encoding's type.
 */

//这里主要是各种值类型的掩码
typedef NS_OPTIONS(NSUInteger, HXEncodingType) {
    HXEncodingTypeMask       = 0xFF, ///掩码是两位的十六进制
    HXEncodingTypeUnknown    = 0, ///< unknown
    HXEncodingTypeVoid       = 1,
    HXEncodingTypeBool       = 2, ///< bool
    HXEncodingTypeInt8       = 3, ///< char / BOOL
    HXEncodingTypeUInt8      = 4, ///< unsigned char
    HXEncodingTypeInt16      = 5, ///< short
    HXEncodingTypeUInt16     = 6, ///< unsigned short
    HXEncodingTypeInt32      = 7, ///< int
    HXEncodingTypeUInt32     = 8, ///< unsigned int
    HXEncodingTypeInt64      = 9, ///< long long
    HXEncodingTypeUInt64     = 10, ///< unsigned long long
    HXEncodingTypeFloat      = 11, ///< float
    HXEncodingTypeDouble     = 12, ///< double
    HXEncodingTypeLongDouble = 13, ///< long double
    HXEncodingTypeObject     = 14, ///< id
    HXEncodingTypeClass      = 15, ///< Class
    HXEncodingTypeSEL        = 16, ///< SEL
    HXEncodingTypeBlock      = 17, ///< block
    HXEncodingTypePointer    = 18, ///< void*
    HXEncodingTypeStruct     = 19, ///< struct
    HXEncodingTypeUnion      = 20, ///< union
    HXEncodingTypeCString    = 21, ///< char*
    HXEncodingTypeCArray     = 22, ///< char[10] (for example)

    ///限定词 const 之类的,
            HXEncodingTypeQualifierMask   = 0xFF00,  ///< mask of qualifier
            HXEncodingTypeQualifierConst  = 1 << 8,  ///< const
            HXEncodingTypeQualifierIn     = 1 << 9,  ///< in
            HXEncodingTypeQualifierInout  = 1 << 10, ///< inout
            HXEncodingTypeQualifierOut    = 1 << 11, ///< out
            HXEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
            HXEncodingTypeQualifierByref  = 1 << 13, ///< byref
            HXEncodingTypeQualifierOneway = 1 << 14, ///< oneway

    ///property 掩码
            HXEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
            HXEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
            HXEncodingTypePropertyCopy         = 1 << 17, ///< copy
            HXEncodingTypePropertyRetain       = 1 << 18, ///< retain
            HXEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
            HXEncodingTypePropertyWeak         = 1 << 20, ///< weak
            HXEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
            HXEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
            HXEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.

 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html

 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */

HXEncodingType hxEncodingGetType(const char *typeEncoding);

/**
 * 成员变量Info抽象类, 是一个不透明(opaque)struct, 所以有补齐
 */
@interface HXClassIvarInfo : NSObject
@property(assign, nonatomic, readonly) Ivar           ivar; ///< ivar opaque struct
@property(strong, nonatomic, readonly) NSString       *name;  ///< Ivar's name
//指针偏移量
@property(assign, nonatomic, readonly) ptrdiff_t      offset;  ///< Ivar's offset
@property(assign, nonatomic, readonly) NSString       *typeEncoding;  ///< Ivar's type encoding
@property(assign, nonatomic, readonly) HXEncodingType type;  ///< Ivar's type

/**
 * Creates and returns an ivar info object.
 * @param ivar ivar ivar opaque struct
 * @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end

@interface HXClassMethodInfo : NSObject
@property(assign, nonatomic, readonly) Method                         method; ///< method opaque struct
@property(strong, nonatomic, readonly) NSString                       *name; ///< method name
@property(assign, nonatomic, readonly) SEL                            sel; ///< method's selector
@property(assign, nonatomic, readonly) IMP                            imp; ///< method's implementation
@property(strong, nonatomic, readonly) NSString                       *typeEncoding; ///< method's parameter and return types
@property(strong, nonatomic, readonly) NSString                       *returnTypeEncoding; ///< return value's type
@property(strong, nonatomic, readonly, nullable) NSArray <NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.

 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end

@interface HXClassPropertyInfo : NSObject
@property(assign, nonatomic, readonly) objc_property_t                property;
@property(strong, nonatomic, readonly) NSString                       *name;
@property(assign, nonatomic, readonly) HXEncodingType                 type;
@property(strong, nonatomic, readonly) NSString                       *typeEncoding;
@property(strong, nonatomic, readonly) NSString                       *ivarName;
@property(assign, nonatomic, nullable, readonly) Class                cls;
@property(strong, nonatomic, nullable, readonly) NSArray <NSString *> *protocols;
@property(assign, nonatomic, readonly) SEL                            getter;
@property(assign, nonatomic, readonly) SEL                            setter;

/**
 Creates and returns a property info object.

 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end

@interface HXClassInfo : NSObject
@property(assign, nonatomic, readonly) Class                                                      cls;
@property(assign, nonatomic, readonly, nullable) Class                                            superCls;
@property(assign, nonatomic, readonly, nullable) Class                                            metaCls;
//这里不知为何 isMeta会这么写
@property(readonly, nonatomic) BOOL                                                               isMeta;
@property(strong, nonatomic, readonly) NSString                                                   *name;
@property(strong, nonatomic, readonly, nullable) HXClassInfo                                      *superClassInfo;
//这里字典的泛型值得学习
@property(strong, nonatomic, readonly, nullable) NSDictionary <NSString *, HXClassIvarInfo *>     *ivarInfos;
@property(strong, nonatomic, readonly, nullable) NSDictionary <NSString *, HXClassMethodInfo *>   *methodInfos;
@property(strong, nonatomic, readonly, nullable) NSDictionary <NSString *, HXClassPropertyInfo *> *propertyInfos;

/**
* @Description:  If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.

 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 如果向class 添加method, 则使用这个方法, 刷新class info的缓存
* @Author: Insomnia
* @Date: 2018/11/14 下午3:09
*/
- (void)setNeedUpdate;

/**
* @Description:  If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
* @return Whether this class info need update.
* @Author: Insomnia
* @Date: 2018/11/14 下午3:11
*/
- (BOOL)needUpdate;

/**
* @Description:  Get the class info of a specified Class.
 This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 获取class info
* @params cls A class.
* @return  A class info, or nil if an error occurs.
* @Author: Insomnia
* @Date: 2018/11/14 下午3:15
*/
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
* @Description: Get the class info of a specified Class.
This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 同上, 参数换成string
* @params className A class name.
* @return A class info, or nil if an error occurs.
* @Author: Insomnia
* @Date: 2018/11/14 下午3:17
*/
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;
@end


NS_ASSUME_NONNULL_END


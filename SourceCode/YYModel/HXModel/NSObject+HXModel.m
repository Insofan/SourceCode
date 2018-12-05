//
//  NSObject+HXModel.m
//  SourceCode
//
//  Created by Insomnia on 2018/11/22.
//  Copyright © 2018 Insomnia. All rights reserved.
//

#import "NSObject+HXModel.h"
#import "HXClassInfo.h"
#import <objc/message.h>

//因为 inline是对编译器的建议, 这里定义了一个强制内联的宏
#define force_inline __inline__ __attribute__((always_inline))

/// Foundation Class Type
typedef NS_ENUM (NSUInteger, HXEncodingNSType) {
    HXEncodingTypeNSUnknown = 0,
    HXEncodingTypeNSString,
    HXEncodingTypeNSMutableString,
    HXEncodingTypeNSValue,
    HXEncodingTypeNSNumber,
    HXEncodingTypeNSDecimalNumber,
    HXEncodingTypeNSData,
    HXEncodingTypeNSMutableData,
    HXEncodingTypeNSDate,
    HXEncodingTypeNSURL,
    HXEncodingTypeNSArray,
    HXEncodingTypeNSMutableArray,
    HXEncodingTypeNSDictionary,
    HXEncodingTypeNSMutableDictionary,
    HXEncodingTypeNSSet,
    HXEncodingTypeNSMutableSet,
};

/// Get the Foundation class type from property info.
static force_inline HXEncodingNSType HXClassGetNSType(Class cls) {
    if (!cls) return HXEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return HXEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return HXEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return HXEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return HXEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return HXEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return HXEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return HXEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return HXEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return HXEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return HXEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return HXEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return HXEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return HXEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return HXEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return HXEncodingTypeNSSet;
    return HXEncodingTypeNSUnknown;
}

/// Parse a number value from 'id'.
static force_inline NSNumber *HXNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet  *dot;
    static NSDictionary    *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE": @(YES),
                @"True": @(YES),
                @"true": @(YES),
                @"FALSE": @(NO),
                @"False": @(NO),
                @"false": @(NO),
                @"YES": @(YES),
                @"Yes": @(YES),
                @"yes": @(YES),
                @"NO": @(NO),
                @"No": @(NO),
                @"no": @(NO),
                @"NIL": (id) kCFNull,
                @"Nil": (id) kCFNull,
                @"nil": (id) kCFNull,
                @"NULL": (id) kCFNull,
                @"Null": (id) kCFNull,
                @"null": (id) kCFNull,
                @"(NULL)": (id) kCFNull,
                @"(Null)": (id) kCFNull,
                @"(null)": (id) kCFNull,
                @"<NULL>": (id) kCFNull,
                @"<Null>": (id) kCFNull,
                @"<null>": (id) kCFNull};
    });

    if (!value || value == (id) kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num != nil) {
            if (num == (id) kCFNull) return nil;
            return num;
        }
        if ([(NSString *) value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *) value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *) value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }


    /// Parse string to date.
    static force_inline NSDate *HXNSDateFromString(__unsafe_unretained NSString *string) {
        typedef NSDate *(^HXNSDateParseBlock)(NSString *string);
#define kParserNum 34
        static HXNSDateParseBlock blocks[kParserNum + 1] = {0};
        static dispatch_once_t    onceToken;
        dispatch_once(&onceToken, ^{
            {
                /*
                 2014-01-20  // Google
                 */
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
                formatter.dateFormat = @"yyyy-MM-dd";
                blocks[10] = ^(NSString *string) {
                    return [formatter dateFromString:string];
                };
            }

            {
                /*
                 2014-01-20 12:24:48
                 2014-01-20T12:24:48   // Google
                 2014-01-20 12:24:48.000
                 2014-01-20T12:24:48.000
                 */
                NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                formatter1.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter1.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
                formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";

                NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
                formatter2.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter2.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
                formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";

                NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
                formatter3.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter3.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
                formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";

                NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
                formatter4.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter4.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
                formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

                blocks[19] = ^(NSString *string) {
                    if ([string characterAtIndex:10] == 'T') {
                        return [formatter1 dateFromString:string];
                    } else {
                        return [formatter2 dateFromString:string];
                    }
                };

                blocks[23] = ^(NSString *string) {
                    if ([string characterAtIndex:10] == 'T') {
                        return [formatter3 dateFromString:string];
                    } else {
                        return [formatter4 dateFromString:string];
                    }
                };
            }

            {
                /*
                 2014-01-20T12:24:48Z        // Github, Apple
                 2014-01-20T12:24:48+0800    // Facebook
                 2014-01-20T12:24:48+12:00   // Google
                 2014-01-20T12:24:48.000Z
                 2014-01-20T12:24:48.000+0800
                 2014-01-20T12:24:48.000+12:00
                 */
                NSDateFormatter *formatter = [NSDateFormatter new];
                formatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

                NSDateFormatter *formatter2 = [NSDateFormatter new];
                formatter2.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";

                blocks[20] = ^(NSString *string) {
                    return [formatter dateFromString:string];
                };
                blocks[24] = ^(NSString *string) {
                    return [formatter dateFromString:string] ?: [formatter2 dateFromString:string];
                };
                blocks[25] = ^(NSString *string) {
                    return [formatter dateFromString:string];
                };
                blocks[28] = ^(NSString *string) {
                    return [formatter2 dateFromString:string];
                };
                blocks[29] = ^(NSString *string) {
                    return [formatter2 dateFromString:string];
                };
            }

            {
                /*
                 Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
                 Fri Sep 04 00:12:21.000 +0800 2015
                 */
                NSDateFormatter *formatter = [NSDateFormatter new];
                formatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";

                NSDateFormatter *formatter2 = [NSDateFormatter new];
                formatter2.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";

                blocks[30] = ^(NSString *string) {
                    return [formatter dateFromString:string];
                };
                blocks[34] = ^(NSString *string) {
                    return [formatter2 dateFromString:string];
                };
            }
        });
        if (!string) return nil;
        if (string.length > kParserNum) return nil;
        HXNSDateParseBlock parser = blocks[string.length];
        if (!parser) return nil;
        return parser(string);
#undef kParserNum
    }
    return nil;
}

/// Get the 'NSBlock' class.
static force_inline Class HXNSBlockClass() {
    static Class           cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{
        };
        cls = ((NSObject *) block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls; // current is "NSBlock"
}

/**
 Get the ISO date formatter.

 ISO8601 format example:
 2010-07-09T16:13:30+12:00
 2011-01-11T11:11:11+0000
 2011-01-26T19:06:43Z

 length: 20/24/25
 */
static force_inline NSDateFormatter *HXISODateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale     = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

/// Get the value with key paths from dictionary
/// The dic should be NSDictionary, and the keyPath should not be nil.
static force_inline id HXValueForKeyPath(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths) {
    id              value = nil;
    for (NSUInteger i     = 0, max = keyPaths.count; i < max; i++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

/// Get the value with multi key (or key path) from dictionary
/// The dic should be NSDictionary
static force_inline id HXValueForMultiKeys(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multiKeys) {
    id            value = nil;
    for (NSString *key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) break;
        } else {
            value = HXValueForKeyPath(dic, (NSArray *) key);
            if (value) break;
        }
    }
    return value;
}

/// A property info in object model.
@interface _HXModelPropertyMeta : NSObject {
@package
    NSString         *_name;             ///< property's name
    HXEncodingType   _type;        ///< property's type
    HXEncodingNSType _nsType;    ///< property's Foundation type
    BOOL             _isCNumber;             ///< is c number type
    Class            _cls;                  ///< property's class, or nil
    Class            _genericCls;           ///< container's generic class, or nil if threr's no generic class
    SEL              _getter;                 ///< getter, or nil if the instances cannot respond
    SEL              _setter;                 ///< setter, or nil if the instances cannot respond
    BOOL             _isKVCCompatible;       ///< YES if it can access with key-value coding
    BOOL             _isStructAvailableForKeyedArchiver; ///< YES if the struct can encoded with keyed archiver/unarchiver
    BOOL             _hasCustomClassFromDictionary; ///< class/generic class implements +modelCustomClassForDictionary:

    /*
     property->key:       _mappedToKey:key     _mappedToKeyPath:nil            _mappedToKeyArray:nil
     property->keyPath:   _mappedToKey:keyPath _mappedToKeyPath:keyPath(array) _mappedToKeyArray:nil
     property->keys:      _mappedToKey:keys[0] _mappedToKeyPath:nil/keyPath    _mappedToKeyArray:keys(array)
     */
    NSString             *_mappedToKey;      ///< the key mapped to
    NSArray              *_mappedToKeyPath;   ///< the key path mapped to (nil if the name is not key path)
    NSArray              *_mappedToKeyArray;  ///< the key(NSString) or keyPath(NSArray) array (nil if not mapped to multiple keys)
    HXClassPropertyInfo  *_info;  ///< property's info
    _HXModelPropertyMeta *_next; ///< next meta if there are multiple properties mapped to the same key.
}
@end

@implementation _HXModelPropertyMeta
+ (instancetype)metaWithClassInfo:(HXClassInfo *)classInfo propertyInfo:(HXClassPropertyInfo *)propertyInfo generic:(Class)generic {

    // support pseudo generic class with protocol name
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }

    _HXModelPropertyMeta *meta = [self new];
    meta->_name       = propertyInfo.name;
    meta->_type       = propertyInfo.type;
    meta->_info       = propertyInfo;
    meta->_genericCls = generic;

    if ((meta->_type & HXEncodingTypeMask) == HXEncodingTypeObject) {
        meta->_nsType = HXClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = HXEncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & HXEncodingTypeMask) == HXEncodingTypeStruct) {
        /*
         It seems that NSKeyedUnarchiver cannot decode NSValue except these structs:
         */
        static NSSet           *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    meta->_cls        = propertyInfo.cls;

    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else if (meta->_cls && meta->_nsType == HXEncodingTypeNSUnknown) {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }

    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }

    if (meta->_getter && meta->_setter) {
        /*
         KVC invalid type:
         long double
         pointer (such as SEL/CoreFoundation object)
         */
        switch (meta->_type & HXEncodingTypeMask) {
            case HXEncodingTypeBool:
            case HXEncodingTypeInt8:
            case HXEncodingTypeUInt8:
            case HXEncodingTypeInt16:
            case HXEncodingTypeUInt16:
            case HXEncodingTypeInt32:
            case HXEncodingTypeUInt32:
            case HXEncodingTypeInt64:
            case HXEncodingTypeUInt64:
            case HXEncodingTypeFloat:
            case HXEncodingTypeDouble:
            case HXEncodingTypeObject:
            case HXEncodingTypeClass:
            case HXEncodingTypeBlock:
            case HXEncodingTypeStruct:
            case HXEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            }
                break;
            default:
                break;
        }
    }

    return meta;
}
@end

/// A class info in object model.
@interface _HXModelMeta : NSObject {
@package
    HXClassInfo      *_classInfo;
    /// Key:mapped key and key path, Value:_HXModelPropertyMeta.
    NSDictionary     *_mapper;
    /// Array<_HXModelPropertyMeta>, all property meta of this model.
    NSArray          *_allPropertyMetas;
    /// Array<_HXModelPropertyMeta>, property meta which is mapped to a key path.
    NSArray          *_keyPathPropertyMetas;
    /// Array<_HXModelPropertyMeta>, property meta which is mapped to multi keys.
    NSArray          *_multiKeysPropertyMetas;
    /// The number of mapped key (and key path), same to _mapper.count.
    NSUInteger       _keyMappedCount;
    /// Model class type.
    HXEncodingNSType _nsType;

    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}
@end

@implementation _HXModelMeta

- (instancetype)initWithClass:(Class)cls {
    HXClassInfo *classInfo = [HXClassInfo classInfoWithClass:cls];
    if (!classInfo) {
        return nil;
    }

    self = [super init];

    //黑名单
    //Get black list
    NSSet *blackList = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *properties = [(id<HXModel>)cls modelPropertyBlacklist];
        if (properties) {
            blackList = [NSSet setWithArray:properties];
        }
    }

    // Get white list
    NSSet *whitelist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *properties = [(id<HXModel>)cls modelPropertyWhitelist];
        if (properties) {
            whitelist = [NSSet setWithArray:properties];
        }
    }


    return self;
}

@end

@implementation NSObject (HXModel)

@end

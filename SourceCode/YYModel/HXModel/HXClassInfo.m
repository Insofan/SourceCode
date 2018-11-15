//
// Created by Insomnia on 2018/11/14.
// Copyright (c) 2018 Insomnia. All rights reserved.
//

#import "HXClassInfo.h"
#import <objc/runtime.h>


HXEncodingType HXEncodingGetType(const char *typeEncoding) {
    ///判断unknown 类型
    char *type  = (char *) typeEncoding;
    if (!type) {
        return HXEncodingTypeUnknown;
    }
    size_t len = strlen(type);
    if (len == 0) {
        return HXEncodingTypeUnknown;
    }
    ///判断修饰符
    HXEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= HXEncodingTypeQualifierConst;
                type++;
            }
                break;
            case 'n': {
                qualifier |= HXEncodingTypeQualifierIn;
                type++;
            }
                break;
            case 'N': {
                qualifier |= HXEncodingTypeQualifierInout;
                type++;
            }
                break;
            case 'o': {
                qualifier |= HXEncodingTypeQualifierOut;
                type++;
            }
                break;
            case 'O': {
                qualifier |= HXEncodingTypeQualifierBycopy;
                type++;
            }
                break;
            case 'R': {
                qualifier |= HXEncodingTypeQualifierByref;
                type++;
            }
                break;
            case 'V': {
                qualifier |= HXEncodingTypeQualifierOneway;
                type++;
            }
                break;
            default: {
                prefix = false;
            }
                break;
        }
    }

    len = strlen(type);
    if (len == 0) {
        return HXEncodingTypeUnknown | qualifier;
    }

    switch (*type) {
        case 'v':
            return HXEncodingTypeVoid | qualifier;
        case 'B':
            return HXEncodingTypeBool | qualifier;
        case 'c':
            return HXEncodingTypeInt8 | qualifier;
        case 'C':
            return HXEncodingTypeUInt8 | qualifier;
        case 's':
            return HXEncodingTypeInt16 | qualifier;
        case 'S':
            return HXEncodingTypeUInt16 | qualifier;
        case 'i':
            return HXEncodingTypeInt32 | qualifier;
        case 'I':
            return HXEncodingTypeUInt32 | qualifier;
        case 'l':
            return HXEncodingTypeInt32 | qualifier;
        case 'L':
            return HXEncodingTypeUInt32 | qualifier;
        case 'q':
            return HXEncodingTypeInt64 | qualifier;
        case 'Q':
            return HXEncodingTypeUInt64 | qualifier;
        case 'f':
            return HXEncodingTypeFloat | qualifier;
        case 'd':
            return HXEncodingTypeDouble | qualifier;
        case 'D':
            return HXEncodingTypeLongDouble | qualifier;
        case '#':
            return HXEncodingTypeClass | qualifier;
        case ':':
            return HXEncodingTypeSEL | qualifier;
        case '*':
            return HXEncodingTypeCString | qualifier;
        case '^':
            return HXEncodingTypePointer | qualifier;
        case '[':
            return HXEncodingTypeCArray | qualifier;
        case '(':
            return HXEncodingTypeUnion | qualifier;
        case '{':
            return HXEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return HXEncodingTypeBlock | qualifier;
            else
                return HXEncodingTypeObject | qualifier;
        }
        default:
            return HXEncodingTypeUnknown | qualifier;
    }
}

@implementation HXClassIvarInfo
- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) {
        return nil;
    }
    //这里防止为初始化
    self  = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }

    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type         = hxEncodingGetType(typeEncoding);
    }
    return self;
}
@end

@implementation HXClassMethodInfo
- (instancetype)initWithMethod:(Method)method {
    if (!method) {
        return nil;
    }
    self    = [super init];
    _method = method;
    _sel    = method_getName(method);
    _imp    = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }

    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);

    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        /// copy 需要 free
        free(returnType);
    }

    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) {
                free(argumentType);
            }
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}
@end

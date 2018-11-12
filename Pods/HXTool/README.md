# HXTool

[![CI Status](http://img.shields.io/travis/Insofan/HXTool.svg?style=flat)](https://travis-ci.org/Insofan/HXTool)
[![Version](https://img.shields.io/cocoapods/v/HXTool.svg?style=flat)](http://cocoapods.org/pods/HXTool)
[![License](https://img.shields.io/cocoapods/l/HXTool.svg?style=flat)](http://cocoapods.org/pods/HXTool)
[![Platform](https://img.shields.io/cocoapods/p/HXTool.svg?style=flat)](http://cocoapods.org/pods/HXTool)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HXTool is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "HXTool"
```

## Usage

1.UIColor with hex string

```
self.view.backgroundColor = [UIColor hx_colorWithRGBString:@"4EBDFB"];
```

or with RGB number

```
self.view.backgroundColor = [UIColor hx_colorWithRGBNumber:78 green:189 blue:151];
```

also random color

```
self.view.backgroundColor = [UIColor hx_randomColor];
```

2.UIButton

```
UIButton *button = [UIButton hx_buttonWithTitle:@"button" fontSize:12 normalColor:[UIColor blueColor] selectedColor:[UIColor whiteColor]];
```

3.Screen frame

```
1.Screen Width and Screen Height
view.frame = CGRectMake(100, 300, [UIScreen hx_screenWidth]/2, [UIScreen hx_screenHeight]/6);
```

4.Macro

```
//App Version
NSLog(@"app version: %@", AppVersion);
```

5.NSArray

```
 //enumerate objects
 [self.array hx_each:^(id obj) {
        NSLog(@"%@",obj);
    }];
```





## Author

Insofan, insofan3156@gmail.com

## License

HXTool is available under the MIT license. See the LICENSE file for more info.

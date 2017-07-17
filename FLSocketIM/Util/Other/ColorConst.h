//
//  ColorConst.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#define RGBAColor(r, g, b, a) [UIColor colorWithRed:((r)/255.0f) green:((g)/255.0f) blue:((b)/255.0f) alpha:(a)]
#define FLRandomColor RGBAColor(arc4random()%255, arc4random()%255, arc4random()%255, 1)
#define FLBackGroundColor   [UIColor colorWithHex:0xefefef]
#define FLNavBGColor        [UIColor colorWithHex:0xf8f8f8]
#define FLSecondColor       [UIColor colorWithHex:0x989898]
#define FLLightGrayColor    [UIColor colorWithHex:0xaaaaaa];

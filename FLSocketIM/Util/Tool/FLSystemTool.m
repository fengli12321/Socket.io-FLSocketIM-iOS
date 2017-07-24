//
//  FLSystemTool.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/24.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLSystemTool.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation FLSystemTool

+ (void)playNotifySound {
    
    SystemSoundID soundID = 1007;
    AudioServicesPlaySystemSound(soundID);
}

@end

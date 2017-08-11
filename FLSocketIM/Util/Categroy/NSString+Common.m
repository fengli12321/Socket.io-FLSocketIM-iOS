//
//  NSString+Common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/17.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Common)

- (NSDictionary *)stringToJsonDictionary {
    
    if (!self.length) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        FLLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString *)creatUUIDString {
    return [[NSUUID UUID] UUIDString];
}

/** 获取文件保存路径 */
+ (NSString *)getFielSavePath{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    path = [path stringByAppendingPathComponent:@"FLFileSavePath"];
    BOOL isDir = false;
    BOOL isExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && isExist)) {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (bCreateDir) {
            
            FLLog(@"文件路径创建成功");
        }
    }
    return path;
}

- (NSString *)md5Str
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark emotion_monkey
+ (NSDictionary *)emotion_specail_dict {
    static NSDictionary *_emotion_specail_dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emotion_specail_dict = @{
                                  //猴子大表情
                                  @"coding_emoji_01": @" :哈哈: ",
                                  @"coding_emoji_02": @" :吐: ",
                                  @"coding_emoji_03": @" :压力山大: ",
                                  @"coding_emoji_04": @" :忧伤: ",
                                  @"coding_emoji_05": @" :坏人: ",
                                  @"coding_emoji_06": @" :酷: ",
                                  @"coding_emoji_07": @" :哼: ",
                                  @"coding_emoji_08": @" :你咬我啊: ",
                                  @"coding_emoji_09": @" :内急: ",
                                  @"coding_emoji_10": @" :32个赞: ",
                                  @"coding_emoji_11": @" :加油: ",
                                  @"coding_emoji_12": @" :闭嘴: ",
                                  @"coding_emoji_13": @" :wow: ",
                                  @"coding_emoji_14": @" :泪流成河: ",
                                  @"coding_emoji_15": @" :NO!: ",
                                  @"coding_emoji_16": @" :疑问: ",
                                  @"coding_emoji_17": @" :耶: ",
                                  @"coding_emoji_18": @" :生日快乐: ",
                                  @"coding_emoji_19": @" :求包养: ",
                                  @"coding_emoji_20": @" :吹泡泡: ",
                                  @"coding_emoji_21": @" :睡觉: ",
                                  @"coding_emoji_22": @" :惊讶: ",
                                  @"coding_emoji_23": @" :Hi: ",
                                  @"coding_emoji_24": @" :打发点咯: ",
                                  @"coding_emoji_25": @" :呵呵: ",
                                  @"coding_emoji_26": @" :喷血: ",
                                  @"coding_emoji_27": @" :Bug: ",
                                  @"coding_emoji_28": @" :听音乐: ",
                                  @"coding_emoji_29": @" :垒码: ",
                                  @"coding_emoji_30": @" :我打你哦: ",
                                  @"coding_emoji_31": @" :顶足球: ",
                                  @"coding_emoji_32": @" :放毒气: ",
                                  @"coding_emoji_33": @" :表白: ",
                                  @"coding_emoji_34": @" :抓瓢虫: ",
                                  @"coding_emoji_35": @" :下班: ",
                                  @"coding_emoji_36": @" :冒泡: ",
                                  @"coding_emoji_38": @" :2015: ",
                                  @"coding_emoji_39": @" :拜年: ",
                                  @"coding_emoji_40": @" :发红包: ",
                                  @"coding_emoji_41": @" :放鞭炮: ",
                                  @"coding_emoji_42": @" :求红包: ",
                                  @"coding_emoji_43": @" :新年快乐: ",
                                  //猴子大表情 Gif
                                  @"coding_emoji_gif_01": @" :奔月: ",
                                  @"coding_emoji_gif_02": @" :吃月饼: ",
                                  @"coding_emoji_gif_03": @" :捞月: ",
                                  @"coding_emoji_gif_04": @" :打招呼: ",
                                  @"coding_emoji_gif_05": @" :悠闲: ",
                                  @"coding_emoji_gif_06": @" :赏月: ",
                                  @"coding_emoji_gif_07": @" :中秋快乐: ",
                                  @"coding_emoji_gif_08": @" :爬爬: ",
                                  //特殊 emoji 字符
//                                  @"0️⃣":	@"0",
//                                  @"1️⃣":	@"1",
//                                  @"2️⃣":	@"2",
//                                  @"3️⃣":	@"3",
//                                  @"4️⃣":	@"4",
//                                  @"5️⃣":	@"5",
//                                  @"6️⃣":	@"6",
//                                  @"7️⃣":	@"7",
//                                  @"8️⃣":	@"8",
//                                  @"9️⃣":	@"9",
//                                  @"↩️":	@"\n",
                                  };
    });
    return _emotion_specail_dict;
}
- (NSString *)emotionSpecailName{
    return [NSString emotion_specail_dict][self];
}
@end

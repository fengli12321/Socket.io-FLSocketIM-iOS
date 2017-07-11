//
//  FLChatDBManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatDBManager.h"
#import <FMDB/FMDB.h>
static FLChatDBManager *instance = nil;

@interface FLChatDBManager ()

@property (nonatomic, strong) FMDatabase *db;

@end
@implementation FLChatDBManager

#pragma mark - init
+ (instancetype)shareManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}


- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
    });
    return instance;
}


#pragma mark - Private
- (NSString *)DBMianPath {
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = @"/Users/fengli/Desktop";
    path = [path stringByAppendingPathComponent:@"MessageGroup"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = false;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (!(isDir && isDirExist)) {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (bCreateDir) {
            
            FLLog(@"文件路径创建成功");
        }
    }
    return path;
}

- (void)creatMessagesListTable {
    
    NSString *tablePath = [[self DBMianPath] stringByAppendingPathComponent:@"MessagesList.db"];
    
    self.db = [FMDatabase databaseWithPath:tablePath];
    if ([self.db open]) {
        
        
    }
    else {
        FLLog(@"数据库打开失败");
    }
}

@end

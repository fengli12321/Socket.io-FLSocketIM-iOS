//
//  FLChatDBManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatDBManager.h"
#import <FMDB/FMDB.h>
#import "FLConversationModel.h"
#import "FLMessageModel.h"
static FLChatDBManager *instance = nil;

@interface FLChatDBManager ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) FMDatabaseQueue *DBQueue;

@end
@implementation FLChatDBManager

#pragma mark - Lazy
- (FMDatabaseQueue *)DBQueue {
    
    NSString *dbName = [NSString stringWithFormat:@"%@.db", [FLClientManager shareManager].currentUserID];
    NSString *path = _DBQueue.path;
    if (!_DBQueue || ![path containsString:dbName]) {
        NSString *tablePath = [[self DBMianPath] stringByAppendingPathComponent:dbName];
        
        _DBQueue = [FMDatabaseQueue databaseQueueWithPath:tablePath];
        [_DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            // 打开数据库
            if ([db open]) {
                
                // 会话数据库表
                BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS conversation (id TEXT NOT NULL, type INT1, ext TEXT, unreadcount Integer, latestmsgid TEXT)"];
                if (success) {
                    FLLog(@"创建会话表成功");
                }
                else {
                    FLLog(@"创建会话表失败");
                }
                
                // 消息数据表
                BOOL msgSuccess = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS message (id TEXT NOT NULL, timestamp INT64, conversation TEXT, msgdirection INT1, chattype TEXT, bodies TEXT)"];
                if (msgSuccess) {
                    FLLog(@"创建消息表成功");
                }
                else {
                    FLLog(@"创建消息表失败");
                }
            }
        }];
    }
    return _DBQueue;
}
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
    path = [path stringByAppendingPathComponent:@"FLChatDB"];
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


/**
 查询会话再数据库是否存在

 @param conversationId 会话的ID
 @param exist 是否存在，且返回db以便下步操作
 */
- (void)conversation:(NSString *)conversationId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist{
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation WHERE id = ?", conversationId];
        while (result.next) {
            e = YES;
            break;
        }
        exist(e, db);
    }];
    
}

- (void)message:(FLMessageModel *)message isExist:(void(^)(BOOL isExist, FMDatabase *db))exist {
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM message WHERE id = ?", message.msg_id];
        while (result.next) {
            
            e = YES;
            break;
        }
        exist(e, db);
    }];
}

- (void)creatMessagesListTable {
    
    
    if ([self.db open]) {
        
        
    }
    else {
        FLLog(@"数据库打开失败");
    }
}

- (FLMessageModel *)makeMessageWithFMResult:(FMResultSet *)result {
    
    NSString *bodies = [result stringForColumnIndex:5];
    FLMessageBody *body = [FLMessageBody yy_modelWithJSON:[bodies stringToJsonDictionary]];
    BOOL isSender = [result boolForColumnIndex:3];
    
    NSString *currentUser = [FLClientManager shareManager].currentUserID;
    NSString *conversation = [result stringForColumnIndex:2];
    NSString *toUser = isSender?conversation:currentUser;
    NSString *fromUser = isSender?currentUser:conversation;
    NSString *chat_type = [result stringForColumnIndex:4];
    long long timeStamp = [result longLongIntForColumnIndex:1];
    NSString *msgId = [result stringForColumnIndex:0];
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:fromUser chatType:chat_type messageBody:body];
    message.timestamp = timeStamp;
    message.msg_id = msgId;
    
    return message;
}

#pragma mark - Public
- (void)addConversation:(FLConversationModel *)conversation {
    
    [self conversation:conversation.userName isExist:^(BOOL isExist, FMDatabase *db) {
        
        // 判断不存在再插入数据库
        if (!isExist) {
            
                
                NSString *toUser = conversation.userName;
                NSInteger unreadCount = conversation.unReadCount;
                NSString *latestMsgId = conversation.latestMsgId;
                [db executeUpdate:@"INSERT INTO conversation (id, unreadcount, latestmsgid) VALUES (?, ?, ?)", toUser, unreadCount, latestMsgId];

        }
    }];
    
}

- (NSArray<FLConversationModel *> *)queryAllConversations {
    
    NSMutableArray *conversations = [NSMutableArray array];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation"];
        while (result.next) {
            FLConversationModel *conversation = [[FLConversationModel alloc] init];
            conversation.userName = [result stringForColumnIndex:0];
            
            // 查询最新一条消息
            NSString *latestMsgId = [result stringForColumnIndex:4];
            FMResultSet *latesMsgRes = [db executeQuery:@"SELECT * FROM message WHERE id = ?", latestMsgId];
            
            while (latesMsgRes.next) {
                
                FLMessageModel *latestMessage = [self makeMessageWithFMResult:latesMsgRes];
                conversation.latestMessage = latestMessage;
                [conversations addObject:conversation];
                break;
            }
            
        }
    }];
    return conversations;
}


- (void)addMessage:(FLMessageModel *)message {
    
    [self message:message isExist:^(BOOL isExist, FMDatabase *db) {
        
       // 判断再数据库中不存在再插入消息
        if (!isExist) {
            BOOL isSender = [message.from isEqualToString:[FLClientManager shareManager].currentUserID];
            NSString *bodies = [message.bodies yy_modelToJSONString];
            NSNumber *time = [NSNumber numberWithLongLong:message.timestamp];
            
            [db executeUpdate:@"INSERT INTO message (id, timestamp, conversation, msgdirection, chattype, bodies) VALUES (?, ?, ?, ?, ?, ?)", message.msg_id, time, isSender?message.to:message.from, isSender?@1:@0, @"chat", bodies];
        }
        
    }];
}

- (NSArray<FLMessageModel *> *)queryMessagesWithUser:(NSString *)userName {
    
    return [self queryMessagesWithUser:userName limit:10000 page:0];
}

- (NSArray<FLMessageModel *> *)queryMessagesWithUser:(NSString *)userName limit:(NSInteger)limit page:(NSInteger)page {
    
    if (limit <= 0) {
        return nil;
    }
    
    NSMutableArray *messages = [NSMutableArray array];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSDate *date = [NSDate date];
        NSNumber *timeStamp = [NSNumber numberWithLongLong:[date timeStamp]*1000];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM message WHERE conversation = ? AND timestamp < ? ORDER BY timestamp DESC LIMIT ? OFFSET ?", userName, timeStamp, @(limit), @(limit*page)];
        while (result.next) {
            
            
            FLMessageModel *message = [self makeMessageWithFMResult:result];
            [messages addObject:message];
        }
    }];
    return messages;
}


@end

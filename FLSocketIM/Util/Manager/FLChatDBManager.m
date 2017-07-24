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
#import "FLChatViewController.h"
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
                BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS conversation (id TEXT NOT NULL, type INT1, ext TEXT, unreadcount Integer, latestmsgtext TEXT, latestmsgtimestamp INT32)"];
                if (success) {
                    FLLog(@"创建会话表成功");
                }
                else {
                    FLLog(@"创建会话表失败");
                }
                
                // 消息数据表
                BOOL msgSuccess = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS message (id TEXT NOT NULL, localtime INT32, timestamp INT32, conversation TEXT, msgdirection INT1, chattype TEXT, bodies TEXT, status INT1)"];
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
    
    FLLog(@"%@======", NSHomeDirectory());
//    path = @"/Users/fengli/Desktop";
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
- (void)conversation:(NSString *)conversationId isExist:(void(^)(BOOL isExist, FMDatabase *db, NSInteger unReadCount))exist{
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL e = NO;
        NSInteger unreadCount = 0;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation WHERE id = ?", conversationId];
        while (result.next) {
            e = YES;
            unreadCount = [result intForColumnIndex:3];
            break;
        }
        exist(e, db, unreadCount);
    }];
    
}

- (void)message:(FLMessageModel *)message baseId:(BOOL)baseId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist {
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL e = NO;
        if (!message.msg_id.length) {
            exist(NO, db);
            return ;
        }
        FMResultSet *result;
        if (baseId) {  // 基于消息ID查询
            result = [db executeQuery:@"SELECT * FROM message WHERE id = ?", message.msg_id];
        }
        else {  // 基于消息发送的本地时间查询
            result = [db executeQuery:@"SELECT * FROM message WHERE localtime = ?", @(message.sendtime)];
        }
        
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
    
    NSString *bodies = [result stringForColumnIndex:6];
    FLMessageBody *body = [FLMessageBody yy_modelWithJSON:[bodies stringToJsonDictionary]];
    BOOL isSender = [result boolForColumnIndex:4];
    
    NSString *currentUser = [FLClientManager shareManager].currentUserID;
    NSString *conversation = [result stringForColumnIndex:3];
    NSString *toUser = isSender?conversation:currentUser;
    NSString *fromUser = isSender?currentUser:conversation;
    NSString *chat_type = [result stringForColumnIndex:5];
    long long timeStamp = [result longLongIntForColumnIndex:2];
    long long localTime = [result longLongIntForColumnIndex:1];
    NSString *msgId = [result stringForColumnIndex:0];
    NSInteger status = [result intForColumnIndex:7];
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:fromUser chatType:chat_type messageBody:body];
    message.timestamp = timeStamp;
    message.msg_id = msgId;
    message.sendtime = localTime;
    message.sendStatus = status?FLMessageSendSuccess:FLMessageSendFail;
    return message;
}

#pragma mark - Public
//- (void)addConversation:(FLConversationModel *)conversation {
//    
//    [self conversation:conversation.userName isExist:^(BOOL isExist, FMDatabase *db) {
//        
//        // 判断不存在再插入数据库
//        if (!isExist) {
//            
//                
//                NSString *toUser = conversation.userName;
//                NSInteger unreadCount = conversation.unReadCount;
//                NSString *latestMsgId = conversation.latestMsgId;
//                [db executeUpdate:@"INSERT INTO conversation (id, unreadcount, latestmsgid) VALUES (?, ?, ?)", toUser, @(unreadCount), latestMsgId];
//
//        }
//    }];
//}

- (NSArray<FLConversationModel *> *)queryAllConversations {
    
    NSMutableArray *conversations = [NSMutableArray array];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation"];
        while (result.next) {
            FLConversationModel *conversation = [[FLConversationModel alloc] init];
            conversation.userName = [result stringForColumnIndex:0];
            conversation.unReadCount = [result intForColumnIndex:3];
            conversation.latestMsgStr = [result stringForColumnIndex:4];
            conversation.latestMsgTimeStamp = [result longLongIntForColumnIndex:5];
            [conversations addObject:conversation];
        }
    }];
    return conversations;
}


- (void)addMessage:(FLMessageModel *)message {
    
    [self message:message baseId:YES isExist:^(BOOL isExist, FMDatabase *db) {
        
       // 判断再数据库中不存在再插入消息
        if (!isExist) {
            BOOL isSender = [message.from isEqualToString:[FLClientManager shareManager].currentUserID];
            NSString *bodies = [message.bodies yy_modelToJSONString];
            NSNumber *time = [NSNumber numberWithLongLong:message.timestamp];
            NSString *msgId = message.msg_id?message.msg_id:@"";
            NSNumber *locTime = [NSNumber numberWithLongLong:message.sendtime];
            NSNumber *status;
            switch (message.sendStatus) {
                case FLMessageSending:
                case FLMessageSendFail:
                    status = @0;
                    break;
                    
                case FLMessageSendSuccess:
                    status = @1;
                    break;
                default:
                    break;
            }
            [db executeUpdate:@"INSERT INTO message (id, localtime, timestamp, conversation, msgdirection, chattype, bodies, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", msgId, locTime,time, isSender?message.to:message.from, isSender?@1:@0, @"chat", bodies, status];
        }
        
    }];
}

- (void)updateMessage:(FLMessageModel *)message {
    
    [self message:message baseId:NO  isExist:^(BOOL isExist, FMDatabase *db) {
        
        NSNumber *sendStatus;
        switch (message.sendStatus) {
            case FLMessageSendFail:case FLMessageSending:
                sendStatus = @0;
                break;
                
            case FLMessageSendSuccess:
                sendStatus = @1;
                break;
            default:
                break;
        }
        // 如果消息存在，更新状态
        if (isExist) {
            
            [db executeUpdate:@"UPDATE message SET status = ?, id = ?, timestamp = ? WHERE localtime = ?", sendStatus, message.msg_id, @(message.timestamp), @(message.sendtime)];
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
        NSNumber *timeStamp = [NSNumber numberWithLongLong:[date timeStamp]];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM message WHERE conversation = ? AND timestamp < ? ORDER BY timestamp DESC LIMIT ? OFFSET ?", userName, timeStamp, @(limit), @(limit*page)];
        while (result.next) {
            
            
            FLMessageModel *message = [self makeMessageWithFMResult:result];
            [messages addObject:message];
        }
    }];
    
    
    // 数组倒序
    for (NSInteger index = 0; index < messages.count / 2; index++) {
        [messages exchangeObjectAtIndex:index withObjectAtIndex:messages.count - index - 1];
    }
    
//    [messages sortUsingComparator:^NSComparisonResult(FLMessageModel * _Nonnull obj1, FLMessageModel *  _Nonnull obj2) {
//        
//        if (obj1.timestamp > obj2.timestamp) {
//            return NSOrderedDescending;
//        }
//        else if (obj1.timestamp < obj2.timestamp) {
//            
//            return NSOrderedAscending;
//        }
//        return NSOrderedSame;
//    }];
    return messages;
}


//- (void)updateLatestMessageOfConversation:(FLConversationModel *)conversation andMessage:(FLMessageModel *)message {
//    
//    if (!message.msg_id) {
//        return;
//    }
//    
//    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        
//        BOOL success = [db executeUpdate:@"UPDATE conversation SET latestmsgid = ? WHERE id = ?", message.msg_id, conversation.userName];
//        
//        if (success) {
//            FLLog(@"更新成功");
//        }
//        else {
//            FLLog(@"更新失败");
//        }
//    }];
//}


- (void)addOrUpdateConversationWithMessage:(FLMessageModel *)message isChatting:(BOOL)isChatting{
    
    if (!message) {
        FLLog(@"message为空");
        return;
    }
    // 自己是否是消息发送者
    BOOL isSender = [message.from isEqualToString:[FLClientManager shareManager].currentUserID];
    // 聊天的对象
    NSString *conversationName = isSender ? message.to : message.from;
    // 最新消息字符
    NSString *latestMsgStr = [FLConversationModel getMessageStrWithMessage:message];
    // 会话是否开启
    [self conversation:conversationName isExist:^(BOOL isExist, FMDatabase *db, NSInteger unreadCount) {
        
        // 判断不存在再插入数据库
        if (!isExist) {
            
            FLConversationModel *conversation = [[FLConversationModel alloc] initWithMessageModel:message conversationId:conversationName];
            conversation.unReadCount = isChatting ? 0 : 1;
            
            NSString *toUser = conversation.userName;
            NSInteger unreadCount = conversation.unReadCount;
            [db executeUpdate:@"INSERT INTO conversation (id, unreadcount, latestmsgtext, latestmsgtimestamp) VALUES (?, ?, ?, ?)", toUser, @(unreadCount), latestMsgStr, @(message.timestamp)];
            
        }
        else {  // 如果已经存在，更新最后一条消息
            
            unreadCount = isChatting ? 0 : (unreadCount + 1);
            BOOL success = [db executeUpdate:@"UPDATE conversation SET latestmsgtext = ?, unreadcount = ?,latestmsgtimestamp = ?  WHERE id = ?", latestMsgStr, @(unreadCount), @(message.timestamp), conversationName];
            
            if (success) {
                FLLog(@"更新成功");
            }
            else {
                FLLog(@"更新失败");
            }
        }
    }];
}

- (void)updateUnreadCountOfConversation:(NSString *)conversationName unreadCount:(NSInteger)unreadCount{
    
    [self conversation:conversationName isExist:^(BOOL isExist, FMDatabase *db, NSInteger unReadCount) {
        
        if (isExist) {
            BOOL success = [db executeUpdate:@"UPDATE conversation SET unreadcount = ? WHERE id = ?", @(unreadCount),conversationName];
            
            if (success) {
                FLLog(@"更新成功");
            }
            else {
                FLLog(@"更新失败");
            }
        }
    }];
}

@end

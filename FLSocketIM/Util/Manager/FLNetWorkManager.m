//
//  FLNetWorkManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLNetWorkManager.h"
#import "AFNetworkActivityIndicatorManager.h"
@implementation FLNetWorkManager

+ (instancetype)shareManager {
    
    static FLNetWorkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[FLNetWorkManager alloc] init];
    });
    return instance;
}
+ (void)initialize {
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        
        SocketIOClient *client = [FLSocketManager shareManager].client;
        if (client && client.status == SocketIOClientStatusDisconnected) {
            
            FLLog(@"重新连接Socket");
            [client connect];
        }
        
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                FLLog(@"未知网络");
                [FLNetWorkManager shareManager].netWorkStatus = NetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                FLLog(@"没有网络");
                [FLNetWorkManager shareManager].netWorkStatus = NetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                FLLog(@"手机自带网络");
                [FLNetWorkManager shareManager].netWorkStatus = NetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                [FLNetWorkManager shareManager].netWorkStatus = NetworkStatusReachableViaWiFi;
                FLLog(@"WIFI在线");
                break;
        }
    }];
    [manager startMonitoring];
}

+ (AFHTTPSessionManager *)sharedAFManager {
    
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        
        /*! 设置请求超时时间 */
        manager.requestSerializer.timeoutInterval = 15;
        
        /*! 设置相应的缓存策略：此处选择不用加载也可以使用自动缓存【注：只有get方法才能用此缓存策略，NSURLRequestReturnCacheDataDontLoad】 */
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        /*! 设置返回数据为json, 分别设置请求以及相应的序列化器 */
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/xml",@"text/plain", @"application/javascript", nil];

    });
    
    return manager;
}
+ (NSString *)strUTF8Encoding:(NSString *)str
{
    /*! ios9适配的话 打开第一个 */
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
}
+ (NSURLSessionTask *)ba_requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParameters:(NSDictionary *)parameters withSuccessBlock:(ResponseSuccess)successBlock withFailureBlock:(ResponseFail)failureBlock {
    
    if (urlString == nil)
    {
        return nil;
    }
    
    if ([FLNetWorkManager shareManager].netWorkStatus == NetworkStatusNotReachable) {   //没有网络
        failureBlock([NSError errorWithDomain:@"connerror" code:0 userInfo:nil]);
        return nil;
    }
    
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    FLLog(@"******************** 请求参数 ***************************");
    FLLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",
          [self sharedAFManager].requestSerializer.HTTPRequestHeaders, (type == Get) ? @"GET":@"POST",[NSMutableString stringWithFormat:@"%@/%@",BaseUrl,URLString], parameters);
    FLLog(@"******************************************************");
    
    NSURLSessionTask *sessionTask = nil;
    
    if (type == Get)
    {
        
        sessionTask = [[self sharedAFManager] GET:[NSMutableString stringWithFormat:@"%@/%@",BaseUrl,URLString] parameters:parameters  progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            if (successBlock)
            {
                
                successBlock(responseObject);
            }
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
        
        }];
        
    }
    else if (type == Post)
    {
        sessionTask = [[self sharedAFManager] POST:[NSMutableString stringWithFormat:@"%@/%@",BaseUrl,URLString] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
       
            if (successBlock)
            {
                
                successBlock(responseObject);
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
                FLLog(@"错误信息：%@",error);
            }
            
        }];
    }
   
    return sessionTask;
}

#pragma mark - 图片上传
+ (NSURLSessionTask *)ba_uploadImageWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters imageData:(NSData *)imageData withSuccessBlock:(ResponseSuccess)successBlock withFailurBlock:(ResponseFail)failureBlock withUpLoadProgress:(UploadProgress)progress {
    if (urlString == nil)
    {
        return nil;
    }
    
    
    [self sharedAFManager].requestSerializer.timeoutInterval = 25;
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    __weak NSData *weakData = imageData;
    NSString *fileName = parameters[@"imageFileName"];
    NSURLSessionTask *sessionTask = nil;
    __weak typeof(self) weakSelf = self;
    sessionTask = [[self sharedAFManager] POST:[NSMutableString stringWithFormat:@"%@/%@",BaseUrl,URLString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        
        if (weakData) {
            // 图片数据不为空才传递
            [formData appendPartWithFileData:weakData name:@"image" fileName:fileName mimeType:@"image/jpg"];
            
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        if (successBlock)
        {
            successBlock(responseObject);
        }
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [weakSelf sharedAFManager].requestSerializer.timeoutInterval = 15;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failureBlock)
        {
            failureBlock(error);
        }
        
        [weakSelf sharedAFManager].requestSerializer.timeoutInterval = 15;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }];
    
    
    return sessionTask;
}


+ (NSURLSessionDownloadTask *)downLoadWithUrl:(NSString *)url progress:(DownloadProgress)progress success:(ResponseSuccess)success fail:(ResponseFail)fail {
    //首先判断网络是否可用
    if ([FLNetWorkManager shareManager].netWorkStatus == NetworkStatusNotReachable) {
        FLLog(@"网络异常,请稍后再试！");
        return nil;
    }else{
        //        NSLog(@"网络不错");
    }
    
    //默认传输的数据类型是二进制
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //构造request对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //使用系统类创建downLoad Task对象
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //下载进度
        if (progress) {
            progress(downloadProgress.fractionCompleted);//完成的百分比
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //拼接存放路径
        NSURL *pathURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        
        //返回下载到哪里(返回值是一个路径)
        return [pathURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //此处已经在主线程了
        if (!error){
            
            //文件名称
            NSString *fileName = filePath.lastPathComponent;
            //沙盒documents路径
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
            //文件路径
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsPath,fileName];
            
            NSData *dataURL = [NSData dataWithContentsOfFile:filePath];
            
            if (success) {
                success(dataURL);
            }
            //如果请求没有错误(请求成功), 则打印地址
            FLLog(@"打印地址-->%@", filePath);
        }else{
            
            if (fail) {
                fail(error);
            }
        }
    }];
    //开始请求
    [task resume];
    return task;
}

@end

//
//  FLNetWorkManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

/*！定义请求类型的枚举 */
typedef NS_ENUM(NSUInteger, HttpRequestType)
{
    /*! get请求 */
    Get = 0,
    /*! post请求 */
    Post
    
};

/*! 使用枚举NS_ENUM:区别可判断编译器是否支持新式枚举,支持就使用新的,否则使用旧的 */
typedef NS_ENUM(NSUInteger, NetworkStatus)
{
    /*! 未知网络 */
    NetworkStatusUnknown           = 0,
    /*! 没有网络 */
    NetworkStatusNotReachable,
    /*! 手机自带网络 */
    NetworkStatusReachableViaWWAN,
    /*! wifi */
    NetworkStatusReachableViaWiFi
};

/*! 定义请求成功的block */
typedef void( ^ ResponseSuccess)(id response);
/*! 定义请求失败的block */
typedef void( ^ ResponseFail)(NSError *error);

/*! 定义上传进度block */
typedef void( ^ UploadProgress)(int64_t bytesProgress,
int64_t totalBytesProgress);
/*! 定义下载进度block */
typedef void( ^ DownloadProgress)(CGFloat);

@interface FLNetWorkManager : NSObject

/*! 获取当前网络状态 */
@property (nonatomic, assign) NetworkStatus  netWorkStatus;

/*!
 *  网络请求方法,block回调
 *
 *  @param type         get / post
 *  @param urlString    请求的地址
 *  @param parameters    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 */
+ (NSURLSessionTask *)ba_requestWithType:(HttpRequestType)type
                           withUrlString:(NSString *)urlString
                          withParameters:(NSDictionary *)parameters
                        withSuccessBlock:(ResponseSuccess)successBlock
                        withFailureBlock:(ResponseFail)failureBlock;

@end

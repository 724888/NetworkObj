//
//  URLSessionManager.m
//  Trans
//
//  Created by LMsgSendNilSelf on 2016/11/13.
//  Copyright © 2016年 p All rights reserved.
//

#import "URLSessionManager.h"
#import "AFNetworking.h"

@interface OrderURLSessionManager ()

/**
 new request identifier
 */
@property(nonatomic,assign)NSUInteger requestIdentifier;


/**
 all callbacks map
 */
@property(nonatomic,strong)NSMutableDictionary *callbacks;

@end

@implementation OrderURLSessionManager

+ (OrderURLSessionManager*)sharedInstance {
    static OrderURLSessionManager *shareManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setTimeoutIntervalForRequest:15];
        shareManager = [[self alloc] initWithSessionConfiguration:configuration];
        shareManager.requestIdentifier = 0;
        shareManager.callbacks = [NSMutableDictionary dictionary];
    });
    
    return shareManager;
}

- (void)syncDataTaskWithRequest:(NSURLRequest *)request completionHandler:(RequestCallBack)completionHandler {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSUInteger index = _requestIdentifier;
    [_callbacks setObject:completionHandler forKey:@(index)];
    _requestIdentifier++;
    
    [[[OrderURLSessionManager sharedInstance]dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        RequestCallBack callback = [_callbacks objectForKey:@(index)];
       
        if (callback) {
            callback(response,responseObject,error);
            [_callbacks removeObjectForKey:@(index)];
        }
        
        dispatch_semaphore_signal(semaphore);
    }]resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)cancelAllOrderTasks {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    _requestIdentifier = 0;
    [_callbacks removeAllObjects];
    [[OrderURLSessionManager sharedInstance].session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        [dataTasks enumerateObjectsUsingBlock:^(__kindof NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        
        dispatch_semaphore_signal(semaphore);
    }];
    
     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end

@implementation SyncURLSessionManager

+(instancetype)sharedInstance {
    static SyncURLSessionManager * httpClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setTimeoutIntervalForRequest:15];
        httpClient = [[self alloc] initWithSessionConfiguration:configuration];
    });
    
    return httpClient;
}

- (void)cancelAllSyncTasks {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[SyncURLSessionManager sharedInstance].session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        [dataTasks enumerateObjectsUsingBlock:^(__kindof NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end

//
//  URLTaskManager.m
//  Trans
//
//  Created by LMsgSendNilSelf on 2016/11/12.
//  Copyright © 2016年 p All rights reserved.
//

#import "URLTaskManager.h"
#import "URLSessionManager.h"

static dispatch_queue_t sync_request_queue() {
    static dispatch_queue_t wp_sync_request_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wp_sync_request_queue = dispatch_queue_create("com.youdao.sync.request.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return wp_sync_request_queue;
}

static dispatch_group_t sync_request_group() {
    static dispatch_group_t wp_sync_request_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wp_sync_request_group = dispatch_group_create();
    });
    
    return wp_sync_request_group;
}

static dispatch_queue_t order_request_queue() {
    static dispatch_queue_t wp_order_request_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wp_order_request_queue = dispatch_queue_create("com.youdao.order.request.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return wp_order_request_queue;
}

@interface ResultModel : NSObject

@property(nonatomic,strong)NSURLResponse *response;
@property(nonatomic,strong)id responseObject;
@property(nonatomic,strong)NSError *error;

@end

@implementation ResultModel

@end

@implementation SyncURLTaskManager

+ (void)postSyncRequests:(NSArray<NSURLRequest *> *)syncRequests callback:(SyncRequestCallBack)callback {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    
    [syncRequests enumerateObjectsUsingBlock:^(NSURLRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_async(sync_request_group(), sync_request_queue(), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [[SyncURLSessionManager sharedInstance]dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                ResultModel *model = [[ResultModel alloc]init];
                model.response = response;
                model.responseObject = responseObject;
                model.error = error;
                
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }];
    
    dispatch_group_notify(sync_request_group(), dispatch_get_main_queue(), ^{
        NSLog(@"all_requests_sync_end");
       
        callback(resultArray);
    });
}

+ (void)cancelAllSyncTasks {
    [[SyncURLSessionManager sharedInstance]cancelAllSyncTasks];
}

@end

@implementation OrderURLTaskManager

+ (void)postOrderRequest:(NSURLRequest *)request callback:(RequestCallBack)callback{
    dispatch_async(order_request_queue(), ^{
        [[OrderURLSessionManager sharedInstance]syncDataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (nil == error) {
                callback(response, responseObject, nil);
            } else {
                callback(response, nil, error);
            }
        }];
    });
}

+ (void)cancelAllOrderTasks {
    [[OrderURLSessionManager sharedInstance]cancelAllOrderTasks];
}

@end

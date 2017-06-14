//
//  URLTaskManager.h
//  Trans
//
//  Created by LMsgSendNilSelf on 2016/11/12.
//  Copyright © 2016年 p All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLSessionManager.h"

typedef void (^SyncRequestCallBack)(NSArray *results);

@interface SyncURLTaskManager : NSObject

/*apply situation: wait until all task end, then excute callback*/
+ (void)postSyncRequests:(NSArray <NSURLRequest *> *)syncRequests callback:(SyncRequestCallBack)callback;
+ (void)cancelAllSyncTasks;

@end

/*------------------------------------------------------------------------------------------------*/

@interface OrderURLTaskManager : NSObject

/*apply situation: one task end, the other begin*/
+ (void)postOrderRequest:(NSURLRequest *)request callback:(RequestCallBack)callback;
+ (void)cancelAllOrderTasks;

@end

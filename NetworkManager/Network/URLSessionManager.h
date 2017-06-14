//
//  URLSessionManager.h
//  Trans
//
//  Created by LMsgSendNilSelf on 2016/11/13.
//  Copyright © 2016年 p All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <UIKit/UIKit.h>

typedef void (^RequestCallBack)(NSURLResponse * response, id  responseObject, NSError * error);

@interface OrderURLSessionManager : AFURLSessionManager

+ (OrderURLSessionManager *)sharedInstance;
- (void)syncDataTaskWithRequest:(NSURLRequest *)request completionHandler:(RequestCallBack)completionHandler;
- (void)cancelAllOrderTasks;

@end

/*------------------------------------------------------------------------------------------------*/

@interface SyncURLSessionManager : AFURLSessionManager

+ (SyncURLSessionManager *)sharedInstance;
- (void)cancelAllSyncTasks;;

@end



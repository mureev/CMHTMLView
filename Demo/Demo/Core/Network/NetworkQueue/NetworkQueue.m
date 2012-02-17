//
//  NetworkQueue.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "NetworkQueue.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation NetworkQueue

static NSOperationQueue* _networkIOQueue;

static NSOperationQueue* get_network_operations_io_queue() {
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_networkIOQueue = [NSOperationQueue new];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	});
	return _networkIOQueue;
}

+ (NSMutableURLRequest*)addHeadersToRequest:(NSURLRequest*)request {
    NSMutableURLRequest* mutableRequest = nil;
    
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        mutableRequest = (NSMutableURLRequest*)request;
    } else {
        mutableRequest = [NSMutableURLRequest requestWithURL:[request URL] cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval];
    }
    
    mutableRequest.timeoutInterval = 15;
    
    return mutableRequest;
}

+ (CancellationBlock)loadWithURLRequest:(NSURLRequest *)urlRequest
                             completion:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error))completion {
    NSURLRequest* sendRequest = [self addHeadersToRequest:urlRequest];
    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:sendRequest];
    
    CancellationBlock block = ^() {
        [requestOperation cancel];
    };
    
    block = [[block copy] autorelease];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(operation.request, operation.response, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(operation.request, operation.response, nil, error);
    }];
    [requestOperation autorelease];
    [get_network_operations_io_queue() addOperation:requestOperation];
    
    return block;
}

+ (void)cancelAll {
    [get_network_operations_io_queue() cancelAllOperations];
}

@end

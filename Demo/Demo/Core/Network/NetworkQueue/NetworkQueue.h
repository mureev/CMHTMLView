//
//  NetworkQueue.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CancellationBlock)();

@interface NetworkQueue : NSObject

+ (CancellationBlock)loadWithURLRequest:(NSURLRequest *)urlRequest
                             completion:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error))completion;

+ (void)cancelAll;

@end

//
//  CMDataStorage.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface CMDataStorage : NSObject

+ (BOOL)isCached:(NSString*)key;
+ (NSString*)pathForDataFile:(NSString*)key;

// Async API (prefered)
+ (void)storeData:(NSData*)data key:(NSString*)key block:(void (^)())block;
+ (void)dataForKey:(NSString*)key block:(void (^)(NSData* data))block;
+ (void)removeCacheForKey:(NSString*)key block:(void (^)())block;

// Sync API
+ (void)storeData:(NSData*)data key:(NSString*)key;
+ (NSData*)dataForKey:(NSString*)key;
+ (void)removeCacheForKey:(NSString*)key;

@end

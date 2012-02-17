//
//  ObjectStorage.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface ObjectStorage : NSObject

+ (BOOL)isCached:(NSString*)key;
+ (void)storeObject:(id <NSCoding>)obj key:(NSString*)key;
+ (void)objectForKey:(NSString*)key block:(void (^)(id obj))block;
+ (id)objectForKey:(NSString*)key;
+ (NSString*)pathForFileCache:(NSString*)key;

@end

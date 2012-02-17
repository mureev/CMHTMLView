//
//  DataStorage.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface DataStorage : NSObject

+ (BOOL)isCached:(NSString*)key;
+ (void)storeData:(NSData*)data key:(NSString*)key;
+ (NSString*)pathForFileCache:(NSString*)key;

@end

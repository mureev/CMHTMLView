//
//  CMDataStorage.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

// Safe file naming using MD5. Remove this define if you want use key as file name.
#define MD5_FOR_KEY

@interface CMDataStorage : NSObject

+ (instancetype)sharedCacheStorage;
+ (instancetype)sharedDocumentsStorage;
+ (instancetype)sharedTemporaryStorage;

/**
 Asynchronously writes data to the specified storage.
 
 Asynchronously call write on separeated GCD queue with key as file name (or MD5 of key). After it writes the data, the method will call block if it specified.
 
 @param data The data to be written. Required.
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 @param block Complition block with result BOOL value. Optional.
 */
- (void)writeData:(NSData *)data key:(NSString *)key block:(void (^)(BOOL succeeds))block;

/**
 Asynchronously reads data from the specified storage / key.
 
 Asynchronously call read on separeated GCD queue with key as file name (or MD5 of key). After it reads the data, the method will call block. If any error occured or there is no file for that key than the data in complition block will be nil.
 
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 @param block Complition block with result NSData value. Required.
 */
- (void)dataForKey:(NSString *)key block:(void (^)(NSData *data))block;

/**
 Asynchronously remove data to the specified storage / key.
 
 Asynchronously call delete on separeated GCD queue with key as file name (or MD5 of key). After it writes the data, the method will call block if it specified.
 
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 @param block Complition block with result BOOL value. Optional.
 */
- (void)removeDataForKey:(NSString *)key block:(void (^)(BOOL succeeds))block;

/**
 Synchronously writes data to the specified storage / key.
 
 Writes the data to the file specified by a given key for current storage.
 
 @param data The data to be written. Required.
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 
 @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)writeData:(NSData *)data key:(NSString *)key;


/**
 Synchronously reads data from the specified storage / key.
 
 Creates and returns a data object by reading every byte from the file specified by a given key in current storage. Without using GCD queue.
 
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 
 @return A data object by reading every byte from the file specified by key. Returns nil if the data object could not be created.
 */
- (NSData *)dataForKey:(NSString *)key;

/**
 Returns whether the cached data pointed to by a key can be reached.
 
 This method synchronously checks if the data at the provided key is cached. Checking reachability is appropriate when making decisions that do not require other immediate operations on the resource, such as periodic maintenance of user interface state that depends on the existence of a specific document. For example, you might remove an item from a download list if the user deletes the file.
 
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 
 @return YES if the data is cached; otherwise, NO.
 */
- (BOOL)isStored:(NSString *)key;

/**
 Returns a file reference URL that points to the original file by key in current storage.
 
 This method just create NSURL object without checking it reachability.
 
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 
 @return The NSURL object with path to file.
 */
- (NSURL *)fileURLWithKey:(NSString *)key;

/**
 Returns a file reference path that points to the original file by key in current storage.
 
 This method just create NSString object without checking it reachability.
 
 @param key The string that will used as file name. Or MD5 of key if MD5_FOR_KEY define exist. Required.
 
 @return The NSString object with file path.
 */
- (NSString *)filePathWithKey:(NSString *)key;

@end

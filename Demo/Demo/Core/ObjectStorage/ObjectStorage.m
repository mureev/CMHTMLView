//
//  ObjectStorage.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "ObjectStorage.h"

#define kCachePath @"objectStorageCache"

@interface ObjectStorage()

@property (retain) NSString* diskCachePath;
@property (retain) NSCache* memoryCache;

+ (NSString*)cacheKeyForKey:(NSString*)key;
+ (NSString*)defaultCachePath;
+ (id)sharedObjectStorage;
- (BOOL)isCached:(NSString*)key;
- (void)storeObject:(id <NSCoding>)obj key:(NSString*)key;
- (void)objectForKey:(NSString*)key block:(void (^)(id obj))block;
- (id)objectForKey:(NSString*)key;
- (NSString*)pathForFile:(NSString*)key;

@end

@implementation ObjectStorage

@synthesize diskCachePath, memoryCache;


#pragma mark - Singleton

static dispatch_queue_t get_disk_io_queue() {
    static dispatch_queue_t _diskIOQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_diskIOQueue = dispatch_queue_create("disk-cache.io", NULL);
	});
	return _diskIOQueue;
}

+ (id)sharedObjectStorage {
    static dispatch_once_t once;
    static ObjectStorage *sharedInstance = nil;
    dispatch_once(&once, ^ { sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.diskCachePath = [ObjectStorage defaultCachePath];
        self.memoryCache = [[NSCache new] autorelease];
    }
    
    return self;
}

+ (NSString*)cacheKeyForKey:(NSString*)key {
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

+ (NSString*)defaultCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:kCachePath];
}

- (void)createDiskCachePath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:self.diskCachePath]) {
            [fileManager createDirectoryAtPath:self.diskCachePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
        }
        [fileManager release];
    });
}


#pragma mark - Public


+ (BOOL)isCached:(NSString*)key {
    return [[ObjectStorage sharedObjectStorage] isCached:key];
}

+ (void)storeObject:(id <NSCoding>)obj key:(NSString*)key {
    [[ObjectStorage sharedObjectStorage] storeObject:obj key:key];
}

+ (void)objectForKey:(NSString*)key block:(void (^)(id obj))block {
    [[ObjectStorage sharedObjectStorage] objectForKey:key block:block];
}

+ (id)objectForKey:(NSString*)key {
    return [[ObjectStorage sharedObjectStorage] objectForKey:key];
}

+ (NSString*)pathForFileCache:(NSString*)key {
    return [[ObjectStorage sharedObjectStorage] pathForFile:key];
}

- (BOOL)isCached:(NSString*)key {
    key = [ObjectStorage cacheKeyForKey:key];
    
    ObjectStorage *objectStorage = [ObjectStorage sharedObjectStorage];
    if ([objectStorage.memoryCache objectForKey:key]) {
        return YES;
    } else {
        NSFileManager *fileManager = [[NSFileManager new] autorelease];
        if ([fileManager fileExistsAtPath:[objectStorage.diskCachePath stringByAppendingPathComponent:key]]) {
            return YES;
        }
        
        return NO;
    }
}

- (void)storeObject:(id <NSCoding>)obj key:(NSString*)key {
    key = [ObjectStorage cacheKeyForKey:key];
    
    // in memory
    [self.memoryCache setObject:obj forKey:key];
    
    // as file
    dispatch_async(get_disk_io_queue(), ^{
        [self createDiskCachePath];
        
        if (![NSKeyedArchiver archiveRootObject:obj toFile:[self.diskCachePath stringByAppendingPathComponent:key]]) {
            // Caching failed for some reason
            return;
        }
    });
}

- (void)objectForKey:(NSString*)key block:(void (^)(id obj))block {
    key = [ObjectStorage cacheKeyForKey:key];
    
    id obj = [self.memoryCache objectForKey:key];
    if (obj) {
        block(obj);
    } else {
        dispatch_async(get_disk_io_queue(), ^{
            id fileObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.diskCachePath stringByAppendingPathComponent:key]];
            if (fileObj) {
                [self.memoryCache setObject:fileObj forKey:key];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                block(fileObj);
            });
        });
    }
}

- (id)objectForKey:(NSString*)key {
    key = [ObjectStorage cacheKeyForKey:key];
    
    id obj = [self.memoryCache objectForKey:key];
    if (obj) {
        return obj;
    } else {
        id fileObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.diskCachePath stringByAppendingPathComponent:key]];
        if (fileObj) {
            dispatch_async(get_disk_io_queue(), ^{
                [self.memoryCache setObject:fileObj forKey:key];
            });
            
            return fileObj;
        } else {
            return nil;
        }
    }
}

- (NSString*)pathForFile:(NSString*)key {
    key = [ObjectStorage cacheKeyForKey:key];
    return [self.diskCachePath stringByAppendingPathComponent:key];
}

@end

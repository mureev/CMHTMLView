//
//  DataStorage.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "DataStorage.h"

#define kCachePath @"DataStorage"

@interface DataStorage()

@property (retain) NSString* diskCachePath;

+ (NSString*)cacheKeyForKey:(NSString*)key;
+ (NSString*)defaultCachePath;
+ (id)sharedDataStorage;

- (BOOL)isCached:(NSString*)key;
- (void)storeData:(NSData*)data key:(NSString*)key;
- (NSString*)pathForFileCache:(NSString*)key;

@end

@implementation DataStorage

@synthesize diskCachePath;


#pragma mark - Singleton

static dispatch_queue_t get_disk_io_queue() {
    static dispatch_queue_t _diskIOQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_diskIOQueue = dispatch_queue_create("disk-cache.io", NULL);
	});
	return _diskIOQueue;
}

+ (id)sharedDataStorage {
    static dispatch_once_t once;
    static DataStorage *sharedInstance = nil;
    dispatch_once(&once, ^ { sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.diskCachePath = [DataStorage defaultCachePath];
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
    return [[DataStorage sharedDataStorage] isCached:key];
}

+ (void)storeData:(NSData*)data key:(NSString*)key {
    [[DataStorage sharedDataStorage] storeData:data key:key];
}

+ (NSString*)pathForFileCache:(NSString*)key {
    return [[DataStorage sharedDataStorage] pathForFileCache:key];
}

- (BOOL)isCached:(NSString*)key {
    key = [DataStorage cacheKeyForKey:key];
    
    DataStorage *dataStorage = [DataStorage sharedDataStorage];
    NSFileManager *fileManager = [[NSFileManager new] autorelease];
    if ([fileManager fileExistsAtPath:[dataStorage.diskCachePath stringByAppendingPathComponent:key]]) {
        return YES;
    }
    
    return NO;
}

- (void)storeData:(NSData*)data key:(NSString*)key {
    key = [DataStorage cacheKeyForKey:key];
    
    // as file
    dispatch_async(get_disk_io_queue(), ^{
        [self createDiskCachePath];
        
        [data writeToFile:[self.diskCachePath stringByAppendingPathComponent:key] atomically:YES];
    });
}



- (NSString*)pathForFileCache:(NSString*)key {
    key = [DataStorage cacheKeyForKey:key];
    return [self.diskCachePath stringByAppendingPathComponent:key];
}

@end

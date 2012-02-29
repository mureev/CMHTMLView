//
//  CMDataStorage.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMDataStorage.h"

#define kCacheSubfolder     @"DataStorage"

@interface CMDataStorage()

+ (NSString*)internalKey:(NSString*)key;

static dispatch_queue_t get_disk_io_queue();
static NSString* diskCachePath();
static void createDiskCachePath();

@end


@implementation CMDataStorage


#pragma mark - Static functions


static dispatch_queue_t get_disk_io_queue() {
    static dispatch_queue_t _diskIOQueue;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_diskIOQueue = dispatch_queue_create("data-disk-cache.io", NULL);
	});
	return _diskIOQueue;
}

static NSString* diskCachePath() {
    static dispatch_once_t onceToken;
    static NSString* path;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:kCacheSubfolder] retain];
    });
    
    return path;
}

static void createDiskCachePath() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fileManager = [[NSFileManager new] autorelease];
        if (![fileManager fileExistsAtPath:diskCachePath()]) {
            [fileManager createDirectoryAtPath:diskCachePath() withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
}


#pragma mark - Public


+ (BOOL)isCached:(NSString*)key {    
    NSFileManager *fileManager = [[NSFileManager new] autorelease];
    if ([fileManager fileExistsAtPath:[CMDataStorage pathForDataFile:key]]) {
        return YES;
    }
    
    return NO;
}

+ (NSString*)pathForDataFile:(NSString*)key {
    NSString* internalKey = [CMDataStorage internalKey:key];
    return [diskCachePath() stringByAppendingPathComponent:internalKey];
}

+ (void)storeData:(NSData*)data key:(NSString*)key block:(void (^)())block {
    dispatch_async(get_disk_io_queue(), ^{
        createDiskCachePath();
        [data writeToFile:[CMDataStorage pathForDataFile:key] atomically:YES];
        
        if (block) {
            block();
        }
    });
}

+ (void)dataForKey:(NSString*)key block:(void (^)(NSData* data))block {
    if (block) {
        if ([CMDataStorage isCached:key]) {
            dispatch_async(get_disk_io_queue(), ^{
                NSData* data = [NSData dataWithContentsOfFile:[CMDataStorage pathForDataFile:key]];
                block(data);
            });
        } else {
            block(nil);
        }
    }
}

+ (void)removeCacheForKey:(NSString*)key block:(void (^)())block {
    if ([CMDataStorage isCached:key]) {
        dispatch_async(get_disk_io_queue(), ^{
            NSFileManager *fileManager = [[NSFileManager new] autorelease];
            [fileManager removeItemAtPath:[CMDataStorage pathForDataFile:key] error:nil];
            
            if (block) {
                block();
            }
        });
    } else if (block) {
        block();
    }
}

+ (void)storeData:(NSData*)data key:(NSString*)key {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [CMDataStorage storeData:data key:key block:^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

+ (NSData*)dataForKey:(NSString*)key {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData* result = nil;
    
    [CMDataStorage dataForKey:key block:^(NSData *data) {
        result = data;
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

+ (void)removeCacheForKey:(NSString*)key {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [CMDataStorage removeCacheForKey:key block:^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - Private


+ (NSString*)internalKey:(NSString*)key {
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}


@end

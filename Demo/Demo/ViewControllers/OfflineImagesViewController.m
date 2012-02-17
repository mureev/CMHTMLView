//
//  OfflineImagesViewController.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "OfflineImagesViewController.h"
#import "CMHTMLView.h"
#import "NetworkQueue.h"
#import "ObjectStorage.h"


@implementation OfflineImagesViewController

- (NSString*)createWebPath:(NSString*) path {
    path = [[NSURL fileURLWithPath:path isDirectory:NO] absoluteString];
    path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSLog(@"path '%@'", path);
    
    return path;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    CMHTMLView* htmlView = [[[CMHTMLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    htmlView.backgroundColor = [UIColor whiteColor];
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    htmlView.blockTags = [NSArray arrayWithObjects:@"iframe", nil];
    
    htmlView.defaultImagePath = [self createWebPath:[[NSBundle mainBundle] pathForResource:@"pixel" ofType:@"png"]];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Image" ofType:@"html"];  
    NSData* htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString* htmlString = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
    
    htmlView.alpha = 0;
    
    htmlView.urlClick = ^(NSString* url) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL Click" message:url delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        [alert release];
    };
    
    htmlView.imageClick = ^(NSString* url) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Click" message:url delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        [alert release];
    };
    
    htmlView.imageLoading = ^(NSString* url, SetImagePathBlock setImage) {
        if ([ObjectStorage isCached:url]) {
            return [self createWebPath:[ObjectStorage pathForFileCache:url]];
        } else {
            [NetworkQueue loadWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] completion:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
                if (!error) {
                    [ObjectStorage storeObject:data key:url];
                    setImage([self createWebPath:[ObjectStorage pathForFileCache:url]]);
                }
            }];
            
            return nil;
        }
    };
    
    [htmlView loadHtmlBody:htmlString competition:^(NSError *error) {
        if (!error) {
            [UIView animateWithDuration:0.2 animations:^{
                htmlView.alpha = 1;
            }];
        }
    }];
    
    [self.view addSubview:htmlView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
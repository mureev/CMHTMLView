//
//  TranslucentViewController.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "TranslucentViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <CMDataStorage/CMDataStorage.h>

#import "CMHTMLView.h"


@interface TranslucentViewController () <CMHTMLViewDelegate>

@end

@implementation TranslucentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    CMHTMLView* htmlView = [[CMHTMLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    htmlView.backgroundColor = [UIColor clearColor];
    htmlView.delegate = self;
    htmlView.alpha = 0;
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:htmlView];
    
    htmlView.blockTags = [NSArray arrayWithObjects:@"iframe", nil];
    
    htmlView.defaultImagePath = [[[NSBundle mainBundle] URLForResource:@"pixel" withExtension:@"png"] absoluteString];
    htmlView.webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    htmlView.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    
    [htmlView loadHtmlBody:[self readHTMLContentFromFile:@"Image"]];
}

- (NSString *)readHTMLContentFromFile:(NSString *)fileName {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];
    NSData* htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString* htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}


#pragma mark - CMHTMLViewDelegate


- (void)htmlViewDidFinishLoad:(CMHTMLView *)htmlView withError:(NSError *)error {
    if (!error) {
        [UIView animateWithDuration:0.2 animations:^{
            htmlView.alpha = 1;
        }];
    } else {
        htmlView.alpha = 0;
    }
}

- (void)htmlViewWillWaitForImage:(CMHTMLView *)htmlView imageUrl:(NSString *)url imagePath:(SetImagePathBlock)path {
    if ([[CMDataStorage sharedCacheStorage] isStored:url]) {
        path([[[CMDataStorage sharedCacheStorage] fileURLWithKey:url] absoluteString]);
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *data = responseObject;
            
            [[CMDataStorage sharedCacheStorage] writeData:data key:url block:^(BOOL succeeds) {
                path([[[CMDataStorage sharedCacheStorage] fileURLWithKey:url] absoluteString]);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)htmlViewDidTapImage:(CMHTMLView *)htmlView imageUrl:(NSString *)imageUrl {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image!" message:imageUrl delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (void)htmlViewDidTapLink:(CMHTMLView *)htmlView linkUrl:(NSString *)linkUrl {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL!" message:linkUrl delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

@end
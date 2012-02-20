//
//  TranslucentViewController.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "TranslucentViewController.h"
#import "CMHTMLView.h"
#import "NetworkQueue.h"
#import "DataStorage.h"


@implementation TranslucentViewController


- (NSString*)createWebPath:(NSString*) path {
    path = [[NSURL fileURLWithPath:path isDirectory:NO] absoluteString];
    path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    return path;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    CMHTMLView* htmlView = [[[CMHTMLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    htmlView.blockTags = [NSArray arrayWithObjects:@"iframe", nil];
    
    htmlView.defaultImagePath = [self createWebPath:[[NSBundle mainBundle] pathForResource:@"pixel" ofType:@"png"]];
    htmlView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    htmlView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    
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
        if ([DataStorage isCached:url]) {
            return [self createWebPath:[DataStorage pathForFileCache:url]];
        } else {
            [NetworkQueue loadWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] completion:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
                if (!error) {
                    [DataStorage storeData:data key:url];
                    setImage([self createWebPath:[DataStorage pathForFileCache:url]]);
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
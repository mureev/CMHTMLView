//
//  CMHTMLView.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMHTMLView.h"

#define kNativeShame                @"ormma"

#define kDefaultDocumentHead        @"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/><style type=\"text/css\">body {margin:0; padding:9px; font-family:\"%@\"; font-size:%f; word-wrap:break-word;} @media (orientation: portrait) { * {max-width : %.0fpx;}} @media (orientation: landscape) { * {max-width : %.0fpx;}} %@</style>"

@interface CMHTMLView() <UIWebViewDelegate>

@property (retain) UIWebView*           webView;
@property (copy) CompetitionBlock       competitionBlock;
@property (retain) NSString*            jsCode;
@property (retain) NSArray*             images;

- (void)setDefaultValues;
+ (void)removeBackgroundFromWebView:(UIWebView*)webView;

@end

@implementation CMHTMLView

@synthesize webView, competitionBlock, jsCode, images, maxSize, blockTags, fontFamily, fontSize, defaultImagePath, imageLoading;
@dynamic scrollView;


#pragma mark - Memory Managment


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.opaque = NO;
        self.webView.delegate = self;
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.scalesPageToFit = NO;
        self.webView.allowsInlineMediaPlayback = YES;
        self.webView.mediaPlaybackRequiresUserAction = NO;
        
        [CMHTMLView removeBackgroundFromWebView:self.webView];      
        [self addSubview:self.webView];
        
        [self setDefaultValues];
    }
    return self;
}

- (void)dealloc {
    self.webView.delegate = nil;
    self.webView = nil;
    self.competitionBlock = nil;
    self.jsCode = nil;
    self.images = nil;
    self.blockTags = nil;
    self.fontFamily = nil;
    self.defaultImagePath = nil;
    self.imageLoading = nil;
    
    [super dealloc];
}


#pragma mark - Public


- (UIScrollView*)scrollView {
    // For iOS 4.0
    for (id subview in self.webView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            return subview;
        }
    }    
    return nil;
}

- (void)loadHtmlBody:(NSString*)html competition:(CompetitionBlock)competition {
    self.competitionBlock = competition;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* resultHTML = html;
        
        // Find all img tags
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<\\s*img[^>]*src=[\\\"|\\'](.*?)[\\\"|\\'][^>]*\\/*>" options:0 error:NULL];
        NSArray *matchs = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        for (NSTextCheckingResult *match in matchs) {
            int captureIndex;
            for (captureIndex = 1; captureIndex < match.numberOfRanges; captureIndex++) {
                NSRange range = [match rangeAtIndex:captureIndex];
                NSString* src = [html substringWithRange:range];
                NSLog(@"Found src '%@'", src);
                
                self.images = [self.images arrayByAddingObject:src];
                
                // Start loading image for src
                if (self.imageLoading) {
                    NSString* path = self.imageLoading(src, ^(NSString* path) {
                        // reload image with js
                    });
                    
                    // TODO: use ranges insted string replace                    
                    if (path) {
                        resultHTML = [resultHTML stringByReplacingOccurrencesOfString:src withString:path];
                    } else if (self.defaultImagePath) {
                        resultHTML = [resultHTML stringByReplacingOccurrencesOfString:src withString:self.defaultImagePath];
                    }
                }
                
                // Add uniq name to img tag
                // Add onClcik js - window.location='';
            }
        }
        
        // Add blocking some HTML tags
        NSString* additionalStyle = @"";
        if (self.blockTags) {
            for (NSString* tag in self.blockTags) {
                additionalStyle = [additionalStyle stringByAppendingFormat:@"%@ {display:none;}", tag];
            }
        }
        
        // Create <head> for page
        NSString* head = [NSString stringWithFormat:kDefaultDocumentHead, self.fontFamily, self.fontSize, self.maxSize.width-18, self.maxSize.height-18, additionalStyle];
        
        // Create full page code
        NSString* body = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", head, html];
        
        // Start loading
        [self.webView loadHTMLString:body baseURL:nil];
    });
}


#pragma mark - Private


- (void)setDefaultValues {
    self.fontFamily = @"Helvetica";
    self.fontSize = 14.0;
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.maxSize = CGSizeMake(320, 480);
    } else {
        self.maxSize = CGSizeMake(768, 1024);
    }
}

+ (void)removeBackgroundFromWebView:(UIWebView*)webView {
    for (UIView* subView in [webView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView* shadowView in [subView subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    [shadowView setHidden:YES];
                }
            }
        }
    }
}


#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqualToString:kNativeShame]) {
        // working on native callback
    } else {
        if (navigationType == UIWebViewNavigationTypeOther && [[[request URL] absoluteString] isEqualToString:@"about:blank"]) {
            return YES;
        } else {        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil];
        }
    }
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.jsCode) {
        [self.webView stringByEvaluatingJavaScriptFromString:self.jsCode];
    }
    
    if (self.competitionBlock) {
        self.competitionBlock(nil);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.competitionBlock) {
        self.competitionBlock(error);
    }
}

@end

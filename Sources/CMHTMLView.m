//
//  CMHTMLView.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMHTMLView.h"

#define kDefaultDocumentHead        @"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/><style type=\"text/css\">body {margin:0; padding:9px; font-family:\"%@\"; font-size:%f; word-wrap:break-word;} @media (orientation: portrait) { * {max-width : %.0fpx;}} @media (orientation: landscape) { * {max-width : %.0fpx;}}</style>"

@interface CMHTMLView() <UIWebViewDelegate>

@property (retain) UIWebView*           webView;
@property (copy) CompetitionBlock       competitionBlock;

+ (void)removeBackgroundFromWebView:(UIWebView*)webView;

@end

@implementation CMHTMLView

@synthesize webView, competitionBlock, maxSize;
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
        
        self.maxSize = CGSizeZero;
    }
    return self;
}

- (void)dealloc {
    self.webView.delegate = nil;
    self.webView = nil;
    self.competitionBlock = nil;
    
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
    
    if (CGSizeEqualToSize(self.maxSize, CGSizeZero)) {
        self.maxSize = CGSizeMake(320, 480);
    }
    
    NSString* head = [NSString stringWithFormat:kDefaultDocumentHead, @"Helvetica", 14.0, self.maxSize.width-18, self.maxSize.height-18];
    
    NSString* body = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", head, html];
    [self.webView loadHTMLString:body baseURL:nil];
}


#pragma mark - Private


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
    if (navigationType == UIWebViewNavigationTypeOther && [[[request URL] absoluteString] isEqualToString:@"about:blank"]) {
        return YES;
    } else {        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil];
    }
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
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

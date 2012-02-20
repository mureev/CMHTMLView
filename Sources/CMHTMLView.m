//
//  CMHTMLView.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMHTMLView.h"

#define kNativeShame                @"native"

#define kDefaultDocumentHead        @"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/><style type=\"text/css\">body {margin:0; padding:9px; font-family:\"%@\"; font-size:%f; word-wrap:break-word;} img,video {height: auto; margin:5px 0 5px 0;} @media (orientation: portrait) { * {max-width : %.0fpx;}} @media (orientation: landscape) { * {max-width : %.0fpx;}} %@</style>"

@interface CMHTMLView() <UIWebViewDelegate>

@property (retain) UIWebView*               webView;
@property (copy) CompetitionBlock           competitionBlock;
@property (retain) NSString*                jsCode;
@property (retain) NSMutableDictionary*     imgURLs;

- (void)setDefaultValues;
+ (void)removeBackgroundFromWebView:(UIWebView*)webView;
+ (NSString*)md5OfString:(NSString*)str;

@end

@implementation CMHTMLView

@synthesize webView, competitionBlock, jsCode, imgURLs, maxWidthPortrait, maxWidthLandscape, blockTags, fontFamily, fontSize, defaultImagePath, disableAHrefForImages, imageLoading, imageClick, urlClick;
@dynamic scrollView, images;


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
        
        self.jsCode = [NSString string];
        self.imgURLs = [NSMutableDictionary dictionary];
        
        [self setDefaultValues];
    }
    return self;
}

- (void)dealloc {
    self.webView.delegate = nil;
    self.webView = nil;
    self.competitionBlock = nil;
    self.jsCode = nil;
    self.imgURLs = nil;
    self.blockTags = nil;
    self.fontFamily = nil;
    self.defaultImagePath = nil;
    self.imageLoading = nil;
    self.imageClick = nil;
    self.urlClick = nil;
    
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

- (NSArray*)images {
    return [self.imgURLs allValues];
}

- (void)loadHtmlBody:(NSString*)html competition:(CompetitionBlock)competition {
    self.competitionBlock = competition;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* resultHTML = html;
        
        // Find all img tags
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<\\s*img[^>]*src=[\\\"|\\'](.*?)[\\\"|\\'][^>]*\\/*>" options:0 error:NULL];
        NSArray *matchs = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        NSUInteger rangeOffset = 0;
        
        for (NSTextCheckingResult *match in matchs) {
            int captureIndex;
            for (captureIndex = 1; captureIndex < match.numberOfRanges; captureIndex++) {
                NSRange range = [match rangeAtIndex:captureIndex];
                NSString* src = [html substringWithRange:range];
                NSString* hash = [CMHTMLView md5OfString:src];
                [self.imgURLs setObject:src forKey:hash];
                
                // Add uniq id to img tag
                NSString* idHTML = [NSString stringWithFormat:@" id=\"%@\"", hash];
                resultHTML = [resultHTML stringByReplacingCharactersInRange:NSMakeRange(range.location+range.length+1+rangeOffset,0) withString:idHTML];
                
                rangeOffset += [idHTML length];
                
                // Add onClcik js - window.location='';
                self.jsCode = [self.jsCode stringByAppendingFormat:@"document.getElementById('%@').addEventListener('click', function(event) {window.location='%@://imageclick?%@';}, false);", hash, kNativeShame, hash];
            }
        }
        
        // Start loading image for src
        if (self.imageLoading) {
            for (NSString* hash in [self.imgURLs allKeys]) {
                NSString* src = [self.imgURLs objectForKey:hash];
                NSString* path = self.imageLoading(src, ^(NSString* path) {
                    if (path && [path length] > 0) {
                        // reload image with js
                        NSString* js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.src ='%@';", hash, path];
                        [self.webView stringByEvaluatingJavaScriptFromString:js];
                    }
                });
                                  
                if (path && [path length] > 0) {
                    resultHTML = [resultHTML stringByReplacingOccurrencesOfString:src withString:path];
                } else if (self.defaultImagePath) {                    
                    resultHTML = [resultHTML stringByReplacingOccurrencesOfString:src withString:self.defaultImagePath];
                }
            }
        }
        
        // Add blocking some HTML tags
        NSString* additionalStyle = @"";
        if (self.blockTags) {
            for (NSString* tag in self.blockTags) {
                additionalStyle = [additionalStyle stringByAppendingFormat:@"%@ {display:none;}", tag];
            }
        }
        
        // Disable <a href=""> for <img> tags
        if (self.disableAHrefForImages) {
            self.jsCode = [self.jsCode stringByAppendingString:@" var link, img, arr;arr = document.getElementsByTagName('img');for (i in arr) {img = arr[i];link = img.parentNode;if (link && link.tagName.toLowerCase() == 'a') {link.removeAttribute('href');}}"];
        }
        
        // Create <head> for page
        NSString* head = [NSString stringWithFormat:kDefaultDocumentHead, self.fontFamily, self.fontSize, self.maxWidthPortrait-18, self.maxWidthLandscape-18, additionalStyle];
        
        // Create full page code
        NSString* body = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", head, resultHTML];
        
        // Start loading
        [self.webView loadHTMLString:body baseURL:nil];
    });
}

- (void)clean {
    // fast cleaning web view
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
}


#pragma mark - Private


- (void)setDefaultValues {
    self.disableAHrefForImages = YES;
    
    self.fontFamily = @"Helvetica";
    self.fontSize = 14.0;
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.maxWidthPortrait = 320;
        self.maxWidthLandscape = 480;
    } else {
        self.maxWidthPortrait = 768;
        self.maxWidthLandscape = 1024;
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

+ (NSString*)md5OfString:(NSString*)str {
    const char *ptr = [str UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}


#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* url = [request URL];
    if ([[url scheme] isEqualToString:kNativeShame]) {
        if ([[url host] isEqualToString:@"imageclick"]) {
            if (self.imageClick) {
                self.imageClick([self.imgURLs objectForKey:[url query]]);
            }
        }
    } else {
        if (navigationType == UIWebViewNavigationTypeOther && [[url absoluteString] isEqualToString:@"about:blank"]) {
            return YES;
        } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            if (self.urlClick) {
                self.urlClick([url absoluteString]);
            }
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

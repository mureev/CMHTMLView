//
//  CMHTMLView.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMHTMLView.h"

#import <sys/time.h>

void NSProfile(const char *name, void (^work)(void)) {
    struct timeval start, end;
    
    gettimeofday(&start, NULL);
    work();
    gettimeofday(&end, NULL);
    
    double startTime = (start.tv_sec * 1000000.0 + start.tv_usec) / 1000000.0;
    double endTime = (end.tv_sec * 1000000.0 + end.tv_usec) / 1000000.0;
    
    printf("NSProfile :: %s took %f seconds\n", name, endTime - startTime);
}

#define kNativeShame                @"native"

#define kDefaultDocumentMeta        @"<meta name=\"viewport\" content=\"initial-scale=1.0; user-scalable=0; minimum-scale=1.0; maximum-scale=1.0\"/><meta name=\"apple-mobile-web-app-capable\" content=\"yes\"/>"

#define kDefaultDocumentHtmlStyle   @"html {-webkit-touch-callout:none; -webkit-tap-highlight-color:rgba(0,0,0,0); -webkit-text-size-adjust:none; word-wrap:break-word;}"

#define kDefaultDocumentBodyStyle   @"body {margin:0; padding:10px 9px; font-family:%@; font-size:%.0f; line-height:%.1f;} a:link {color: #3A75C4; text-decoration: underline;} img,video,iframe {display:block; padding:0 0 5px; margin:0 auto;} table {font-size:10px;} * {overflow-x:hidden;}"

#define kDefaultDocumentRotateStyle @"@media (orientation:portrait) { img,video,iframe,div {max-width:%.0fpx; height:auto;}} @media (orientation:landscape) { img,video,iframe,div {max-width:%.0fpx; height:auto;}}"

#define kFastClickJs                @"self.FastClick=function(){function k(a){return/\bneedsclick\b/.test(a.className)||{select:!0,input:!0,label:!0,video:!0}[a.nodeName.toLowerCase()]}var l=-1===navigator.userAgent.indexOf(\"PlayBook\")?5:20;return function(a){var d=0,e=0,g=0,h=0,b=!1,m=Math.pow(15,2),n=function(c){b=!0;d=c.targetTouches[0].pageX;e=c.targetTouches[0].pageY;d===c.targetTouches[0].clientX&&(d+=window.pageXOffset);e===c.targetTouches[0].clientY&&(e+=window.pageYOffset);g=window.pageXOffset;h=window.pageYOffset;return!0},o=function(c){if(!b)return!0;Math.pow(c.targetTouches[0].pageX-d,2)+Math.pow(c.targetTouches[0].pageY-e,2)>m&&(b=!1);if(Math.abs(window.pageXOffset-g)>l||Math.abs(window.pageYOffset-h)>l)b=!1;return!0},p=function(c){var a,j,f,i;if(!b)return!0;b=!1;a=d-g;j=e-h;f=document.elementFromPoint(a,j);if(!f)return!1;f.nodeType===Node.TEXT_NODE&&(f=f.parentElement);if(k(f))return!1;i=document.createEvent(\"MouseEvents\");i.initMouseEvent(\"click\",!0,!0,window,1,0,0,a,j,!1,!1,!1,!1,0,null);i.forwardedTouchEvent=!0;f.dispatchEvent(i);;return!1},q=function(){b=!1},r=function(a){var b;if(a.forwardedTouchEvent||!a.cancelable)return!0;b=document.elementFromPoint(d-g,e-h);return!b||!k(b)?(a.stopPropagation(),a.preventDefault(),a.stopImmediatePropagation&&a.stopImmediatePropagation(),!1):!0};if(!a||!a.nodeType)throw new TypeError(\"Layer must be a document node\");\"undefined\"!==typeof window.ontouchstart&&(a.addEventListener(\"click\",r,!0),a.addEventListener(\"touchstart\",n,!0),a.addEventListener(\"touchmove\",o,!0),a.addEventListener(\"touchend\",p,!0),a.addEventListener(\"touchcancel\",q,!0),\"function\"===typeof a.onclick&&(a.addEventListener(\"click\",a.onclick,!1),a.onclick=null))}}(); window.addEventListener('load', function() {new FastClick(document.body);}, false);"


@interface CMHTMLView () <UIWebViewDelegate>

@property (nonatomic, readwrite) UIWebView *webView;

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) CGPoint lastContentOffset;
@property (nonatomic) NSString *jsCode;
@property (nonatomic) NSMutableDictionary *imgURLforHash;

@end

@implementation CMHTMLView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.opaque = NO;
        self.webView.delegate = self;
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.scalesPageToFit = NO;
        self.webView.allowsInlineMediaPlayback = YES;
        self.webView.mediaPlaybackRequiresUserAction = NO;
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;

        [CMHTMLView removeBackgroundFromWebView:self.webView];
        [self addSubview:self.webView];

        // Add observer for scroll
        [self.webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];

        self.jsCode = [NSString string];
        self.imgURLforHash = [NSMutableDictionary dictionary];

        [self setDefaultValues];
        [self prepareForReuse];
    }
    return self;
}

- (void)dealloc {
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    self.webView.delegate = nil;
}


#pragma mark - Public


- (void)loadHtmlBody:(NSString *)html {
    self.loading = YES;
    
    NSString *loadHTML = [self prepareImagesInHtml:html];
    loadHTML = [self loadImagesBasedOnHtml:loadHTML];
    
    // Add blocking some HTML tags
    NSString *localacAdditionalStyle = self.additionalStyle;
    if (!localacAdditionalStyle) {
        localacAdditionalStyle = @"";
    }
    
    if (self.blockTags) {
        for (NSString *tag in self.blockTags) {
            localacAdditionalStyle = [localacAdditionalStyle stringByAppendingFormat:@"%@ {display:none;}", tag];
        }
    }
    
    // Disable <a href=""> for <img> tags
    if (self.disableAHrefForImages) {
        self.jsCode = [self.jsCode stringByAppendingString:@" var link, img, arr;arr = document.getElementsByTagName('img');for (i in arr) {img = arr[i];link = img.parentNode;if (link && link.tagName.toLowerCase() == 'a') {link.removeAttribute('href');}}"];
    }
    
    // Create <head> for page
    NSString *bodyStyle = [NSString stringWithFormat:kDefaultDocumentBodyStyle, self.fontFamily, self.fontSize, self.lineHeight];
    NSString *rotateStyle = [NSString stringWithFormat:kDefaultDocumentRotateStyle, self.maxWidthPortrait - 18, self.maxWidthLandscape - 18];
    
    // Create full page code
    NSString *body = [NSString stringWithFormat:@"<html><head><script type=\"text/javascript\">%@</script> %@ <style type=\"text/css\">%@ %@ %@ %@</style></head><body>%@</body></html>", kFastClickJs, kDefaultDocumentMeta, kDefaultDocumentHtmlStyle, bodyStyle, rotateStyle, localacAdditionalStyle, loadHTML];
    
    // Start loading
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:body baseURL:baseURL];
}

- (void)prepareForReuse {
    // stop loading UIWebView
    [self.webView stopLoading];

    // fast cleaning web view
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];

    self.loading = NO;
    self.jsCode = [NSString string];
    self.imgURLforHash = [NSMutableDictionary dictionary];
}


#pragma mark - KVO


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (!self.isLoading && !CGPointEqualToPoint(self.lastContentOffset, self.webView.scrollView.contentOffset)) {
            self.lastContentOffset = self.webView.scrollView.contentOffset;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(htmlViewDidScroll:)]) {
                [self.delegate htmlViewDidScroll:self];
            }
        }
    }
}


#pragma mark - Private


- (void)setDefaultValues {
    self.disableAHrefForImages = YES;

    self.fontFamily = [CMHTMLView getSystemFont];
    self.fontSize = 14.0;
    self.lineHeight = 1.4;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.maxWidthPortrait = [UIScreen mainScreen].bounds.size.width;
        self.maxWidthLandscape = [UIScreen mainScreen].bounds.size.height;
    } else {
        self.maxWidthPortrait = 570;
        self.maxWidthLandscape = 570;
    }
}

- (NSString *)prepareImagesInHtml:(NSString *)html {
    static dispatch_once_t onceToken;
    static NSRegularExpression *imgRegex;
    dispatch_once(&onceToken, ^{
        imgRegex = [[NSRegularExpression alloc] initWithPattern:@"<img[^>]*src=[\\\"|\\'](.*?)[\\\"|\\'][^>]*\\/*>" options:NSRegularExpressionCaseInsensitive error:nil];
    });

    NSArray *matchs = [imgRegex matchesInString:html options:0 range:NSMakeRange(0, html.length)];

    NSInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matchs) {
        NSRange imgRange = NSMakeRange([match rangeAtIndex:0].location + rangeOffset, [match rangeAtIndex:0].length);
        NSRange srcRange = NSMakeRange([match rangeAtIndex:1].location + rangeOffset, [match rangeAtIndex:1].length);
        NSString *src = [html substringWithRange:srcRange];
        NSString *hash = [NSString stringWithFormat:@"%d", [src hash]];
        [self.imgURLforHash setObject:src forKey:hash];

        // Add uniq id to img tag
        NSString *img = [NSString stringWithFormat:@"<img id=\"%@\" src=\"%@\"/alt=\"%@\">", hash, src, NSLocalizedString(@"CMHTMLView_Image_Alt", nil)];
        html = [html stringByReplacingCharactersInRange:imgRange withString:img];

        rangeOffset += img.length - imgRange.length;

        // Add onClcik js - window.location='';
        self.jsCode = [self.jsCode stringByAppendingFormat:@"document.getElementById('%@').addEventListener('click', function(event) {window.location='%@://imageclick?%@';}, false);", hash, kNativeShame, hash];
    }

    return html;
}

- (NSString *)loadImagesBasedOnHtml:(NSString *)html {
    if (self.delegate && [self.delegate respondsToSelector:@selector(htmlViewWillWaitForImage:imageUrl:imagePath:)]) {
        for (NSString *hash in [self.imgURLforHash allKeys]) {
            NSString *src = [self.imgURLforHash objectForKey:hash];

            if (src && src.length > 0 && hash && hash.length > 0) {
                [self.delegate htmlViewWillWaitForImage:self imageUrl:src imagePath:^(NSString *path) {
                    if (!self.isLoading) {
                        if (path && [path length] > 0) {
                            // reload image with js
                            NSString *js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.src ='%@';", hash, path];
                            [self.webView stringByEvaluatingJavaScriptFromString:js];
                        } else {
                            // disable image
                            NSString *js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.style.display='none';", hash];
                            [self.webView stringByEvaluatingJavaScriptFromString:js];
                        }
                    } else {
                        if (path && [path length] > 0) {
                            // reload image with js
                            NSString *js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.src ='%@';", hash, path];
                            self.jsCode = [self.jsCode stringByAppendingString:js];
                        } else {
                            if (self.jsCode) {
                                NSString *js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.style.display='none';", hash];
                                self.jsCode = [self.jsCode stringByAppendingString:js];
                            }
                        }
                    }
                }];

                if (self.defaultImagePath) {
                    html = [html stringByReplacingOccurrencesOfString:src withString:self.defaultImagePath];
                } else {
                    NSString *js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.style.display='none';", hash];
                    self.jsCode = [self.jsCode stringByAppendingString:js];
                }
            }
        }
    }

    return html;
}

+ (NSString *)getSystemFont {
    static dispatch_once_t onceToken;
    static NSString *font;

    dispatch_once(&onceToken, ^{
        //get system default font 
        //font = [UIFont systemFontOfSize:[UIFont systemFontSize]].fontName;

        font = @"'HelveticaNeue-Light', 'HelveticaNeue'";
    });

    return font;
}

+ (void)removeBackgroundFromWebView:(UIWebView *)webView {
    for (UIView *subView in [webView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView *shadowView in [subView subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    [shadowView setHidden:YES];
                }
            }
        }
    }
}


#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:kNativeShame]) {
        if ([[url host] isEqualToString:@"imageclick"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(htmlViewDidTapImage:imageUrl:)]) {
                [self.delegate htmlViewDidTapImage:self imageUrl:[self.imgURLforHash objectForKey:[url query]]];
            }
        }
    } else {
        if ([[url absoluteString] isEqualToString:@"about:blank"]) {
            return YES;
        } else if ([[url scheme] isEqualToString:@"file"]) {
            return YES;
        } else if ([[url absoluteString] rangeOfString:@"www.youtube.com"].location != NSNotFound) {
            return YES;
        } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(htmlViewDidTapLink:linkUrl:)]) {
                [self.delegate htmlViewDidTapLink:self linkUrl:[url absoluteString]];
            }
        } else if (navigationType == UIWebViewNavigationTypeOther) {
            NSLog(@"Deny load url from UIWebView - %@", [url absoluteString]);
            return NO;
        }
    }

    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loading = NO;

    // make shure what all modifications of self.jsCode property are done
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        if (self.jsCode) {
            [self.webView stringByEvaluatingJavaScriptFromString:self.jsCode];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(htmlViewDidFinishLoad:withError:)]) {
            [self.delegate htmlViewDidFinishLoad:self withError:nil];
        }

    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.loading = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(htmlViewDidFinishLoad:withError:)]) {
        [self.delegate htmlViewDidFinishLoad:self withError:error];
    }
}

@end

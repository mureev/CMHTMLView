//
//  CMHTMLView.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "CMHTMLView.h"

#define kNativeShame                @"native"

#define kDefaultDocumentMeta        @"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0; user-scalable=0; minimum-scale=1.0; maximum-scale=1.0\"/><meta name=\"apple-mobile-web-app-capable\" content=\"yes\"/>"

#define kDefaultDocumentHtmlStyle   @"html {-webkit-tap-highlight-color:rgba(0,0,0,0); -webkit-text-size-adjust:none; word-wrap:break-word;}"

#define kDefaultDocumentBodyStyle   @"body {margin:0; padding:10px 9px; font-family:%@; font-size:%.0f; line-height:%.1f;} a:link {color: #3A75C4; text-decoration: underline;} img,video,iframe {display:block; padding:0 0 5px; margin:0 auto;} table {font-size:10px;} * {overflow-x:hidden;}"

#define kDefaultDocumentRotateStyle @"@media (orientation:portrait) { img,video,iframe,div {max-width:%.0fpx; height:auto;}} @media (orientation:landscape) { img,video,iframe,div {max-width:%.0fpx; height:auto;}}"

#define kFastClickJs                @"self.FastClick=function(){function k(a){return/\bneedsclick\b/.test(a.className)||{select:!0,input:!0,label:!0,video:!0}[a.nodeName.toLowerCase()]}var l=-1===navigator.userAgent.indexOf(\"PlayBook\")?5:20;return function(a){var d=0,e=0,g=0,h=0,b=!1,m=Math.pow(37,2),n=function(c){b=!0;d=c.targetTouches[0].pageX;e=c.targetTouches[0].pageY;d===c.targetTouches[0].clientX&&(d+=window.pageXOffset);e===c.targetTouches[0].clientY&&(e+=window.pageYOffset);g=window.pageXOffset;h=window.pageYOffset;return!0},o=function(c){if(!b)return!0;Math.pow(c.targetTouches[0].pageX-d,2)+Math.pow(c.targetTouches[0].pageY-e,2)>m&&(b=!1);if(Math.abs(window.pageXOffset-g)>l||Math.abs(window.pageYOffset-h)>l)b=!1;return!0},p=function(c){var a,j,f,i;if(!b)return!0;b=!1;a=d-g;j=e-h;f=document.elementFromPoint(a,j);if(!f)return!1;f.nodeType===Node.TEXT_NODE&&(f=f.parentElement);if(k(f))return!1;i=document.createEvent(\"MouseEvents\");i.initMouseEvent(\"click\",!0,!0,window,1,0,0,a,j,!1,!1,!1,!1,0,null);i.forwardedTouchEvent=!0;f.dispatchEvent(i);c.preventDefault();return!1},q=function(){b=!1},r=function(a){var b;if(a.forwardedTouchEvent||!a.cancelable)return!0;b=document.elementFromPoint(d-g,e-h);return!b||!k(b)?(a.stopPropagation(),a.preventDefault(),a.stopImmediatePropagation&&a.stopImmediatePropagation(),!1):!0};if(!a||!a.nodeType)throw new TypeError(\"Layer must be a document node\");\"undefined\"!==typeof window.ontouchstart&&(a.addEventListener(\"click\",r,!0),a.addEventListener(\"touchstart\",n,!0),a.addEventListener(\"touchmove\",o,!0),a.addEventListener(\"touchend\",p,!0),a.addEventListener(\"touchcancel\",q,!0),\"function\"===typeof a.onclick&&(a.addEventListener(\"click\",a.onclick,!1),a.onclick=null))}}(); window.addEventListener('load', function() {new FastClick(document.body);}, false);"


@interface CMHTMLView() <UIWebViewDelegate>

@property (assign) BOOL                     loaded;
@property (retain) UIWebView*               webView;
@property (copy) CompetitionBlock           competitionBlock;
@property (retain) NSString*                jsCode;
@property (retain) NSMutableDictionary*     imgURLforHash;
@property (retain) NSMutableArray*          imgURLs;

- (void)setDefaultValues;
- (NSString *)prepareImagesInHtml:(NSString *)html;
- (NSString *)simplifyTablesInHtml:(NSString *)html;
- (NSString *)removeExtraLineBreaksInHtml:(NSString *)html;
- (NSString *)loadImagesBasedOnHtml:(NSString *)html;
- (NSString *)removeTag:(NSString *)tag html:(NSString *)html;
- (NSString *)extendYouTubeSupportInHtml:(NSString *)html;
- (NSString *)disableIFrameForNonSupportedSrcInHtml:(NSString *)html;

+ (NSString *)getSystemFont;
+ (void)removeBackgroundFromWebView:(UIWebView *)webView;
+ (NSString *)md5OfString:(NSString *)str;

@end

@implementation CMHTMLView

@synthesize loaded, webView, competitionBlock, jsCode, imgURLforHash, imgURLs, maxWidthPortrait, maxWidthLandscape, blockTags, removeTags, fontFamily, fontSize, lineHeight, defaultImagePath, disableAHrefForImages, additionalStyle, imageLoading, imageClick, urlClick;
@dynamic scrollView, images;


#pragma mark - Memory Managment


- (id)initWithFrame:(CGRect)frame {
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
        self.imgURLforHash = [NSMutableDictionary dictionary];
        self.imgURLs = [NSMutableArray array];
        
        [self setDefaultValues];
    }
    return self;
}

- (void)dealloc {
    self.webView.delegate = nil;
    self.webView = nil;
    self.competitionBlock = nil;
    self.jsCode = nil;
    self.imgURLforHash = nil;
    self.imgURLs = nil;
    self.blockTags = nil;
    self.removeTags = nil;
    self.fontFamily = nil;
    self.defaultImagePath = nil;
    self.additionalStyle = nil;
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
    return [NSArray arrayWithArray:self.imgURLs];
}

- (void)loadHtmlBody:(NSString*)html competition:(CompetitionBlock)competition {
    self.competitionBlock = competition;
    [self clean];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* loadHTML = [self prepareImagesInHtml:html];
        loadHTML = [self loadImagesBasedOnHtml:loadHTML];
        loadHTML = [self simplifyTablesInHtml:loadHTML];
        loadHTML = [self removeExtraLineBreaksInHtml:loadHTML];
        loadHTML = [self extendYouTubeSupportInHtml:loadHTML];
        loadHTML = [self disableIFrameForNonSupportedSrcInHtml:loadHTML];
        
        // Add blocking some HTML tags
        NSString *localacAdditionalStyle = self.additionalStyle;
        if (!localacAdditionalStyle) {
            localacAdditionalStyle = @"";
        }
        
        if (self.blockTags) {
            for (NSString* tag in self.blockTags) {
                localacAdditionalStyle = [localacAdditionalStyle stringByAppendingFormat:@"%@ {display:none;}", tag];
            }
        }
        
        // Remove some HTML tags
        if (self.removeTags) {
            for (NSString* tag in self.removeTags) {
                loadHTML = [self removeTag:tag html:loadHTML];
            }
        }
        
        // Disable <a href=""> for <img> tags
        if (self.disableAHrefForImages) {
            self.jsCode = [self.jsCode stringByAppendingString:@" var link, img, arr;arr = document.getElementsByTagName('img');for (i in arr) {img = arr[i];link = img.parentNode;if (link && link.tagName.toLowerCase() == 'a') {link.removeAttribute('href');}}"];
        }
        
        // Create <head> for page
        NSString* bodyStyle = [NSString stringWithFormat:kDefaultDocumentBodyStyle, self.fontFamily, self.fontSize, self.lineHeight];
        NSString* rotateStyle = [NSString stringWithFormat:kDefaultDocumentRotateStyle, self.maxWidthPortrait-18, self.maxWidthLandscape-18];
        
        // Create full page code
        NSString* body = [NSString stringWithFormat:@"<html><head><script type=\"text/javascript\">%@</script> %@ <style type=\"text/css\">%@ %@ %@ %@</style></head><body>%@</body></html>", kFastClickJs, kDefaultDocumentMeta, kDefaultDocumentHtmlStyle, bodyStyle, rotateStyle, localacAdditionalStyle, loadHTML];
        
        // Start loading
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [self.webView loadHTMLString:body baseURL:baseURL];
    });
}

- (void)clean {
    self.loaded = NO;
    self.jsCode = [NSString string];
    [self.imgURLs removeAllObjects];
    [self.imgURLforHash removeAllObjects];
    
    // fast cleaning web view
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
}

- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString*)script {
    return [self.webView stringByEvaluatingJavaScriptFromString:script];
}


#pragma mark - Private


- (void)setDefaultValues {
    self.disableAHrefForImages = YES;
    
    self.fontFamily = [CMHTMLView getSystemFont];
    self.fontSize = 14.0;
    self.lineHeight = 1.4;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.maxWidthPortrait = 320;
        self.maxWidthLandscape = 480;
    } else {
        self.maxWidthPortrait = 768;
        self.maxWidthLandscape = 1024;
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
        NSString* src = [html substringWithRange:srcRange];
        NSString* hash = [CMHTMLView md5OfString:src];
        [self.imgURLforHash setObject:src forKey:hash];
        [self.imgURLs addObject:src];
        
        // Add uniq id to img tag
        NSString* img = [NSString stringWithFormat:@"<img id=\"%@\" src=\"%@\"/>", hash, src];
        html = [html stringByReplacingCharactersInRange:imgRange withString:img];
        
        rangeOffset += img.length - imgRange.length;
        
        // Add onClcik js - window.location='';
        self.jsCode = [self.jsCode stringByAppendingFormat:@"document.getElementById('%@').addEventListener('click', function(event) {window.location='%@://imageclick?%@';}, false);", hash, kNativeShame, hash];
    }
    
    return html;
}

- (NSString *)simplifyTablesInHtml:(NSString *)html {
    static dispatch_once_t onceToken;
    static NSRegularExpression *tableRegex;
    dispatch_once(&onceToken, ^{
        tableRegex = [[NSRegularExpression alloc] initWithPattern:@"<table.*width(.?)['|\"].*>" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    NSArray *matchs = [tableRegex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    NSInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matchs) {
        NSRange widthRange = NSMakeRange([match rangeAtIndex:1].location - 5 + rangeOffset, [match rangeAtIndex:1].length);
        
        html = [html stringByReplacingCharactersInRange:widthRange withString:@""];
        
        rangeOffset -= widthRange.length;
    }
    
    return html;
}

- (NSString *)removeExtraLineBreaksInHtml:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"> <" withString:@"><"];
    html = [html stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    // Doubled <br> replace
    static dispatch_once_t onceToken;
    static NSRegularExpression *brRegex;
    dispatch_once(&onceToken, ^{
        brRegex = [[NSRegularExpression alloc] initWithPattern:@"<br[^>]*>\\s*<br[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    html = [brRegex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, [html length]) withTemplate:@"<br>"];
    
    return html;
}

- (NSString *)loadImagesBasedOnHtml:(NSString *)html {
    if (self.imageLoading) {
        for (NSString* hash in [self.imgURLforHash allKeys]) {
            NSString* src = [self.imgURLforHash objectForKey:hash];
            NSString* path = self.imageLoading(src, ^(NSString* path) {
                if (self.loaded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (path && [path length] > 0) {
                            // reload image with js
                            NSString* js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.src ='%@';", hash, path];
                            [self.webView stringByEvaluatingJavaScriptFromString:js];
                        } else {
                            // disable image
                            NSString* js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.style.display='none';", hash];
                            [self.webView stringByEvaluatingJavaScriptFromString:js];
                        }
                    });
                } else {
                    if (path && [path length] > 0) {
                        // reload image with js
                        NSString* js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.src ='%@';", hash, path];
                        self.jsCode = [self.jsCode stringByAppendingString:js];
                    } else {
                        // disable image
                        if (self.imgURLs) {
                            [self.imgURLs removeObject:src];
                        }
                        
                        if (self.jsCode) {
                            NSString* js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.style.display='none';", hash];
                            self.jsCode = [self.jsCode stringByAppendingString:js];
                        }
                    }
                }
            });
            
            if (path && [path length] > 0) {
                html = [html stringByReplacingOccurrencesOfString:src withString:path];
            } else if (self.defaultImagePath) {
                html = [html stringByReplacingOccurrencesOfString:src withString:self.defaultImagePath];
            } else {
                NSString* js = [NSString stringWithFormat:@"var obj = document.getElementById('%@'); obj.style.display='none';", hash];
                self.jsCode = [self.jsCode stringByAppendingString:js];
            }
        }
    }
    
    return html;
}

- (NSString *)removeTag:(NSString *)tag html:(NSString *)html {
    NSString* pattern = [NSString stringWithFormat:@"</?\\s*%@[^>]*>", tag];
    NSRegularExpression *removeTagExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matchs = [removeTagExpression matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    NSInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matchs) {
        NSRange tagRange = NSMakeRange(match.range.location + rangeOffset, match.range.length);
        html = [html stringByReplacingCharactersInRange:tagRange withString:@""];
        
        rangeOffset -= tagRange.length;
    }
    
    return html;
}

- (NSString *)extendYouTubeSupportInHtml:(NSString *)html {
    static dispatch_once_t onceToken;
    static NSRegularExpression *youtubeEmbedRegex;
    dispatch_once(&onceToken, ^{
        youtubeEmbedRegex = [[NSRegularExpression alloc] initWithPattern:@"<object.*src.*/v/(.*?)['|\"].*object\\s*>" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    NSArray *matchs = [youtubeEmbedRegex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    NSInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matchs) {
        NSRange objectRange = NSMakeRange([match rangeAtIndex:0].location + rangeOffset, [match rangeAtIndex:0].length);
        NSRange idRange = NSMakeRange([match rangeAtIndex:1].location + rangeOffset, [match rangeAtIndex:1].length);
        NSString* youtubrId = [html substringWithRange:idRange];
        
        // Add uniq id to img tag
        NSString* iframe = [NSString stringWithFormat:@"<iframe src=\"http://www.youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen></iframe>", youtubrId];
        html = [html stringByReplacingCharactersInRange:objectRange withString:iframe];
        
        rangeOffset += iframe.length - objectRange.length;
    }
    
    return html;
}

- (NSString *)disableIFrameForNonSupportedSrcInHtml:(NSString *)html {
    static dispatch_once_t onceToken;
    static NSRegularExpression *iframeRegex;
    dispatch_once(&onceToken, ^{
        iframeRegex = [[NSRegularExpression alloc] initWithPattern:@"<iframe[^>]*src=[\\\"|\\'](.*?)[\\\"|\\'].*/\\s*iframe\\s*>" options:0 error:nil];
    });
    
    NSArray *matchs = [iframeRegex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    NSInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matchs) {
        NSRange iframeRange = NSMakeRange([match rangeAtIndex:0].location + rangeOffset, [match rangeAtIndex:0].length);
        NSRange srcRange = NSMakeRange([match rangeAtIndex:1].location + rangeOffset, [match rangeAtIndex:1].length);
        NSString* src = [html substringWithRange:srcRange];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:src]];
        BOOL allowIframe = [self webView:self.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];
        if (!allowIframe) {
            html = [html stringByReplacingCharactersInRange:iframeRange withString:@""];
            
            rangeOffset -= iframeRange.length;
        }
    }
    
    return html;
}

+ (NSString*)getSystemFont {
    static dispatch_once_t onceToken;
    static NSString* font;
    
    dispatch_once(&onceToken, ^{
        //get system default font
        //font = [[UIFont systemFontOfSize:[UIFont systemFontSize]].fontName retain];
        
        font = @"'HelveticaNeue-Light', 'HelveticaNeue'";
    });
    
    return font;
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
                self.imageClick([self.imgURLforHash objectForKey:[url query]]);
            }
        }
    } else {
        if ([[url absoluteString] isEqualToString:@"about:blank"]) {
            return YES;
        } else if ([[url scheme] isEqualToString:@"file"]) {
            return YES;
        } else if ([[url host] isEqualToString:@"www.youtube.com"]) {
            return YES;
        } else if ([[url host] isEqualToString:@"player.vimeo.com"]) {
            return YES;
        } else if ([url.absoluteString rangeOfString:@"src=http://www.youtube"].location != NSNotFound) {
            //http://reader.googleusercontent.com/reader/embediframe?src=http://www.youtube.com/v/4OD770n60cA?version%3D3%26hl%3Dpt_BR&width=640&height=360
            return NO;
        } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            if (self.urlClick) {
                self.urlClick([url absoluteString]);
            }
        } else if (navigationType == UIWebViewNavigationTypeOther) {
            NSLog(@"Deny load url from UIWebView - %@", [url absoluteString]);
            return NO;
        }
    }
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loaded = YES;
    
    if (self.jsCode) {
        // make shure what all modifications of self.jsCode property are done
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.webView stringByEvaluatingJavaScriptFromString:self.jsCode];
            
            if (self.competitionBlock) {
                self.competitionBlock(nil);
            }
            
        });
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.competitionBlock) {
        self.competitionBlock(error);
    }
}

@end

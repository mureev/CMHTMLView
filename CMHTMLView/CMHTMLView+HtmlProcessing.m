//
//  CMHTMLView+HtmlProcessing.m
//  Demo CMHTMLView
//
//  Created by Constantine Mureev on 29/01/14.
//  Copyright (c) 2014 Team Force LLC. All rights reserved.
//

#import "CMHTMLView+HtmlProcessing.h"

@implementation CMHTMLView (HtmlProcessing)

+ (NSString *)prepareHTML:(NSString *)html removeTags:(NSArray *)removeTags {
    if (removeTags) {
        for (NSString *tag in removeTags) {
            html = [self removeTag:tag html:html];
        }
    }
    
    html = [self simplifyTablesInHtml:html];
    html = [self removeExtraLineBreaksInHtml:html];
    html = [self extendYouTubeSupportInHtml:html];
    html = [self disableIFrameForNonSupportedSrcInHtml:html];
    return html;
}

+ (NSString *)simplifyTablesInHtml:(NSString *)html {
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

+ (NSString *)removeExtraLineBreaksInHtml:(NSString *)html {
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
+ (NSString *)extendYouTubeSupportInHtml:(NSString *)html {
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
        NSString *youtubrId = [html substringWithRange:idRange];
        
        // Add uniq id to img tag
        NSString *iframe = [NSString stringWithFormat:@"<iframe src=\"http://www.youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen></iframe>", youtubrId];
        html = [html stringByReplacingCharactersInRange:objectRange withString:iframe];
        
        rangeOffset += iframe.length - objectRange.length;
    }
    
    return html;
}

+ (NSString *)disableIFrameForNonSupportedSrcInHtml:(NSString *)html {
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
        NSString *src = [html substringWithRange:srcRange];
        
        if (![CMHTMLView shoudAllowURL:src]) {
            html = [html stringByReplacingCharactersInRange:iframeRange withString:@""];
            
            rangeOffset -= iframeRange.length;
        }
    }
    
    return html;
}

+ (NSString *)removeTag:(NSString *)tag html:(NSString *)html {
    NSString *pattern = [NSString stringWithFormat:@"</?\\s*%@[^>]*>", tag];
    NSRegularExpression *removeTagExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matchs = [removeTagExpression matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    NSInteger rangeOffset = 0;
    for (NSTextCheckingResult *match in matchs) {
        NSRange tagRange = NSMakeRange(match.range.location + rangeOffset, match.range.length);
        
        if (tagRange.location + tagRange.length <= html.length) {
            html = [html stringByReplacingCharactersInRange:tagRange withString:@""];
            rangeOffset -= tagRange.length;
        }
    }
    
    return html;
}

+ (BOOL)shoudAllowURL:(NSString *)url {
    if ([url isEqualToString:@"about:blank"]) {
        return YES;
    } else if ([url isEqualToString:@"file"]) {
        return YES;
    } else if ([url rangeOfString:@"www.youtube.com"].location != NSNotFound) {
        return YES;
    } else if ([url isEqualToString:@"player.vimeo.com"]) {
        return YES;
    } else {
        return NO;
    }
}

@end

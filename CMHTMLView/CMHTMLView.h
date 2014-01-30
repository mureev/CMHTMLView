//
//  CMHTMLView.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+HtmlProcessing.h"

typedef void (^SetImagePathBlock)(NSString *path);

@protocol CMHTMLViewDelegate;

@interface CMHTMLView : UIView

@property (nonatomic, weak) id <CMHTMLViewDelegate> delegate;
@property (nonatomic, readonly) UIWebView *webView;

@property (nonatomic) CGFloat maxWidthPortrait;
@property (nonatomic) CGFloat maxWidthLandscape;
@property (nonatomic) NSArray *blockTags;
@property (nonatomic) NSString *fontFamily;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) NSString *defaultImagePath;
@property (nonatomic) BOOL disableAHrefForImages;
@property (nonatomic) NSString *additionalStyle;

- (void)loadHtmlBody:(NSString *)html;
- (void)prepareForReuse;

@end

@protocol CMHTMLViewDelegate <NSObject>

@optional

- (void)htmlViewDidFinishLoad:(CMHTMLView *)htmlView withError:(NSError *)error;

- (void)htmlViewWillWaitForImage:(CMHTMLView *)htmlView imageUrl:(NSString *)url imagePath:(SetImagePathBlock)path;

- (void)htmlViewDidScroll:(CMHTMLView *)htmlView;

- (void)htmlViewDidTapImage:(CMHTMLView *)htmlView imageUrl:(NSString *)imageUrl;

- (void)htmlViewDidTapLink:(CMHTMLView *)htmlView linkUrl:(NSString *)linkUrl;

@end

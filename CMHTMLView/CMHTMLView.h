//
//  CMHTMLView.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h> // for MD5 hash

typedef void (^SetImagePathBlock)(NSString *path);

typedef void (^ImagePathBlock)(NSString *url, SetImagePathBlock setImage);

@protocol CMHTMLViewDelegate;

@interface CMHTMLView : UIView

@property (nonatomic, weak) id <CMHTMLViewDelegate> delegate;
@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic) CGFloat maxWidthPortrait;
@property (nonatomic) CGFloat maxWidthLandscape;
@property (nonatomic) NSArray *blockTags;
@property (nonatomic) NSArray *removeTags;
@property (nonatomic) NSString *fontFamily;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) NSString *defaultImagePath;
@property (nonatomic) BOOL disableAHrefForImages;
@property (nonatomic) NSString *additionalStyle;

- (void)loadHtmlBody:(NSString *)html;

- (void)clean;

// JS API
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

- (void)prepeareForRelease;

@end

@protocol CMHTMLViewDelegate <NSObject>

@optional

- (void)htmlViewDidFinishLoad:(CMHTMLView *)htmlView withError:(NSError *)error;

- (void)htmlViewDidScroll:(CMHTMLView *)htmlView;

- (void)htmlViewDidTapImage:(CMHTMLView *)htmlView imageUrl:(NSString *)imageUrl;

- (void)htmlViewDidTapLink:(CMHTMLView *)htmlView linkUrl:(NSString *)linkUrl;

@end

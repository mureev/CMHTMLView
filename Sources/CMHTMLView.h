//
//  CMHTMLView.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h> // for MD5 hash

typedef void (^CompetitionBlock)(NSError* error);
typedef void (^SetImagePathBlock)(NSString* path);
typedef NSString* (^ImagePathBlock)(NSString* url, SetImagePathBlock setImage);
typedef void (^ImageClickBlock)(NSString* url);
typedef void (^UrlClickBlock)(NSString* url);

@interface CMHTMLView : UIView

@property (readonly) UIScrollView*      scrollView;
@property (readonly) NSArray*           images;

@property (assign) CGFloat              maxWidthPortrait;
@property (assign) CGFloat              maxWidthLandscape;
@property (retain) NSArray*             blockTags;
@property (retain) NSString*            fontFamily;
@property (assign) CGFloat              fontSize;
@property (retain) NSString*            defaultImagePath;
@property (assign) BOOL                 disableAHrefForImages;

// Callbacks
@property (retain) ImagePathBlock       imageLoading;
@property (retain) ImageClickBlock      imageClick;
@property (retain) UrlClickBlock        urlClick;

- (void)loadHtmlBody:(NSString*)html competition:(CompetitionBlock)competition;

@end

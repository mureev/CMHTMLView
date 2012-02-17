//
//  CMHTMLView.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompetitionBlock)(NSError* error);
typedef void (^SetImagePathBlock)(NSString* path);
typedef NSString* (^ImagePathBlock)(NSString* url, SetImagePathBlock setImage);

@interface CMHTMLView : UIView

@property (readonly) UIScrollView*      scrollView;
@property (readonly) NSArray*           images;

@property (assign) CGSize               maxSize;
@property (retain) NSArray*             blockTags;
@property (retain) NSString*            fontFamily;
@property (assign) CGFloat              fontSize;

@property (retain) NSString*            defaultImagePath;
@property (retain) ImagePathBlock       imageLoading;

- (void)loadHtmlBody:(NSString*)html competition:(CompetitionBlock)competition;

@end

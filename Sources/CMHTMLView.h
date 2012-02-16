//
//  CMHTMLView.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompetitionBlock)(NSError* error);

@interface CMHTMLView : UIView

@property (assign) CGSize               maxSize;
@property (readonly) UIScrollView*      scrollView;


- (void)loadHtmlBody:(NSString*)html competition:(CompetitionBlock)competition;

@end

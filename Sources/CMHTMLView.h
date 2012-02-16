//
//  CMHTMLView.h
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMHTMLView : UIView

@property (readonly) UIScrollView*      scrollView;


- (void)loadHtmlBody:(NSString*)html;

@end

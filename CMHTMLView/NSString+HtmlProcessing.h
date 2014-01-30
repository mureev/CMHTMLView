//
//  NSString+HtmlProcessing.h
//
//  Created by Constantine Mureev on 30/01/14.
//  Copyright (c) 2014 Team Force LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HtmlProcessing)

- (NSString *)prepareHTML;

- (NSString *)prepareHTMLAndRemoveTags:(NSArray *)removeTags;

@end

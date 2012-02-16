//
//  TranslucentViewController.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "TranslucentViewController.h"
#import "CMHTMLView.h"


@implementation TranslucentViewController


- (void)viewDidLoad {
    [super viewDidLoad];    
    CMHTMLView* htmlView = [[[CMHTMLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    htmlView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    htmlView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Simple" ofType:@"html"];  
    NSData* htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString* htmlString = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
    
    htmlView.alpha = 0;
    
    [htmlView loadHtmlBody:htmlString competition:^(NSError *error) {
        if (!error) {
            [UIView animateWithDuration:0.2 animations:^{
                htmlView.alpha = 1;
            }];
        }
    }];
    
    [self.view addSubview:htmlView];
    
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
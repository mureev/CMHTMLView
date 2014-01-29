//
//  VideoViewController.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "VideoViewController.h"
#import "CMHTMLView.h"


@implementation VideoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CMHTMLView* htmlView = [[CMHTMLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:htmlView];
    
    [htmlView loadHtmlBody:[self readHTMLContentFromFile:@"Video"]];
}

- (NSString *)readHTMLContentFromFile:(NSString *)fileName {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];
    NSData* htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString* htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}

@end
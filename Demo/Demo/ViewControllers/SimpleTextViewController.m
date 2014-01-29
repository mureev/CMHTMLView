//
//  SimpleTextViewController.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "SimpleTextViewController.h"
#import "CMHTMLView.h"


@interface SimpleTextViewController () <CMHTMLViewDelegate>

@end

@implementation SimpleTextViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CMHTMLView* htmlView = [[CMHTMLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    htmlView.delegate = self;
    htmlView.alpha = 0;
    htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [htmlView loadHtmlBody:[self readHTMLContentFromFile:@"Simple"]];
    
    [self.view addSubview:htmlView];
}

- (NSString *)readHTMLContentFromFile:(NSString *)fileName {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];
    NSData* htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString* htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}


#pragma mark - CMHTMLViewDelegate


- (void)htmlViewDidFinishLoad:(CMHTMLView *)htmlView withError:(NSError *)error {
    if (!error) {
        [UIView animateWithDuration:0.2 animations:^{
            htmlView.alpha = 1;
        }];
    } else {
        htmlView.alpha = 0;
    }
}

- (void)htmlViewDidTapImage:(CMHTMLView *)htmlView imageUrl:(NSString *)imageUrl {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image!" message:imageUrl delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (void)htmlViewDidTapLink:(CMHTMLView *)htmlView linkUrl:(NSString *)linkUrl {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL!" message:linkUrl delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

@end
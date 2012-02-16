//
//  AppDelegate.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "AppDelegate.h"

#import "SimpleTextViewController.h"
#import "TextAndImagesViewController.h"
#import "HugeTextViewController.h"
#import "VideoViewController.h"
#import "TranslucentViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // init view controllers
    SimpleTextViewController* simpleTextViewController = [[SimpleTextViewController new] autorelease];
    simpleTextViewController.tabBarItem.image = [UIImage imageNamed:@"text.png"];
    simpleTextViewController.title = @"Simple";
    
    TextAndImagesViewController* textAndImagesViewController = [[TextAndImagesViewController new] autorelease];
    textAndImagesViewController.tabBarItem.image = [UIImage imageNamed:@"image.png"];
    textAndImagesViewController.title = @"Images";
    
    HugeTextViewController* hugeTextViewController = [[HugeTextViewController new] autorelease];
    hugeTextViewController.tabBarItem.image = [UIImage imageNamed:@"book.png"];
    hugeTextViewController.title = @"Huge Text";
    
    VideoViewController* videoViewController = [[VideoViewController new] autorelease];
    videoViewController.tabBarItem.image = [UIImage imageNamed:@"video.png"];
    videoViewController.title = @"Video";
    
    TranslucentViewController* translucentViewController = [[TranslucentViewController new] autorelease];
    translucentViewController.tabBarItem.image = [UIImage imageNamed:@"translucent.png"];
    translucentViewController.title = @"Translucent";
        
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:simpleTextViewController, textAndImagesViewController, hugeTextViewController, videoViewController, translucentViewController, nil];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end

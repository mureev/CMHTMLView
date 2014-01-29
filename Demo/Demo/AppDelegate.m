//
//  AppDelegate.m
//
//  Created by Constantine Mureev on 16.02.12.
//  Copyright (c) 2012 Team Force LLC. All rights reserved.
//

#import "AppDelegate.h"

#import "SimpleTextViewController.h"
#import "OfflineImagesViewController.h"
#import "HugeTextViewController.h"
#import "VideoViewController.h"
#import "TranslucentViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc {
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // init view controllers
    SimpleTextViewController* simpleTextViewController = [SimpleTextViewController new];
    simpleTextViewController.tabBarItem.image = [UIImage imageNamed:@"text.png"];
    simpleTextViewController.title = @"Simple";
    
    OfflineImagesViewController* offlineImagesViewController = [OfflineImagesViewController new];
    offlineImagesViewController.tabBarItem.image = [UIImage imageNamed:@"image.png"];
    offlineImagesViewController.title = @"Images";
    
    HugeTextViewController* hugeTextViewController = [HugeTextViewController new];
    hugeTextViewController.tabBarItem.image = [UIImage imageNamed:@"book.png"];
    hugeTextViewController.title = @"Huge Text";
    
    VideoViewController* videoViewController = [VideoViewController new];
    videoViewController.tabBarItem.image = [UIImage imageNamed:@"video.png"];
    videoViewController.title = @"Video";
    
    TranslucentViewController* translucentViewController = [TranslucentViewController new];
    translucentViewController.tabBarItem.image = [UIImage imageNamed:@"translucent.png"];
    translucentViewController.title = @"Translucent";
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:translucentViewController];
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:simpleTextViewController, offlineImagesViewController, hugeTextViewController, videoViewController, navController, nil];
    
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

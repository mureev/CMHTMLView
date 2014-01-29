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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

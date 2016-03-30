//
//  AppDelegate.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-4.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "APService.h"
#import <AudioToolbox/AudioToolbox.h>
#import "XHBaseNavigationController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

+(AppDelegate*)Share{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //为Manager 对象指定使用HTTP 响应解析器
    self.manger = [AFHTTPRequestOperationManager manager];
    self.manger.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [[Utility Share] readUserInfoFromDefault];
    NSString *UserIdStr  = [[Utility Share] userId];
    NSString *PriviteStr = [[Utility Share] priviteKey];
    if (!UserIdStr && !PriviteStr){
        LoginViewController *loginView = [[LoginViewController alloc] init];
        _LoginNav = [[XHBaseNavigationController alloc] initWithRootViewController:loginView];
        _LoginNav.navigationBar.translucent = NO;
        self.window.rootViewController = _LoginNav;
    }else{
        MainViewController *MainView = [[MainViewController alloc] init];
        _MainNav = [[XHBaseNavigationController alloc] initWithRootViewController:MainView];
        self.MainNav.navigationBar.translucent = NO;
        self.window.rootViewController = _MainNav;
    }
    application.applicationIconBadgeNumber = 0;
    [self.window makeKeyAndVisible];
//    //获取当前版本号
//    [self GetVersionInfo];
    //推送
    // Required
    #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                                       categories:nil];
    }else{
        
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                                       categories:nil];
    }
    #else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                                   categories:nil];
    #endif
    // Required
    [APService setupWithOption:launchOptions];
    return YES;
}


-(void)GetVersionInfo{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@",BASEURL,CustomerApp,@"1.0"];
    [[AppDelegate Share].manger GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
}

#pragma mark APServicae Delegate
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [APService registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [APService handleRemoteNotification:userInfo];
}


-(void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    // IOS7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminatedsonWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}





- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




@end

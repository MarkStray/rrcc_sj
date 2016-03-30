//
//  AppDelegate.h
//  rrcc_sj
//
//  Created by lawwilte on 15-5-4.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "XHBaseNavigationController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
+(AppDelegate*)Share;//单例
@property (strong,nonatomic) UIWindow *window;
@property (strong,nonatomic) XHBaseNavigationController *MainNav;
@property (strong,nonatomic) XHBaseNavigationController *LoginNav;
@property (strong,nonatomic) AFHTTPRequestOperationManager *manger;
@end


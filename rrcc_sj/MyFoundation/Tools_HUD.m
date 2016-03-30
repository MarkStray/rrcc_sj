//
//  Tools_HUD.m
//  yuexiang
//
//  Created by kyl on 13-11-18.
//  Copyright (c) 2013年 kyl. All rights reserved.
//

#import "Tools_HUD.h"
#import "JHNotificationManager.h"


MBProgressHUD *HUD;
@implementation Tools_HUD

+ (Tools_HUD*)shareTools_MBHUD
{
    static Tools_HUD *instance = nil;
    @synchronized(self){
        if (!instance) {
            instance = [[Tools_HUD alloc] init];
        }
    }
    
    return instance;
}




- (void)creatHUD{
    if (HUD) {
        [self hudWasHidden:HUD];
    }
 	HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    HUD.delegate = self;
	[[UIApplication sharedApplication].keyWindow addSubview:HUD];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
    HUD.delegate = nil;
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}


- (void)showBusying
{
    [self creatHUD];
    HUD.labelText = @"请稍等";
    [HUD show:YES];
}
-(void)hideBusying
{
    if (HUD)
    {
        [HUD hide:YES];
    }
    
}


-(void)alertTitle:(NSString *)str{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
    [self dismss:alert];
}


-(void)dismss:(UIAlertView*)alert{
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark-
#pragma mark ---------提示条---------
-(void)notificationWithMessage:(NSString*)text inView:(UIView*)view delay:(CGFloat)delay
{
    [JHNotificationManager notificationWithMessage:text inView:view delay:delay];
}

-(void)notificationWithMessage:(NSString*)text
{
//    if([text isEqualToString:tip_noNet])return;
    if ([text isEqualToString:tip_noNet]) {
        [JHNotificationManager notificationWithMessage:text];
        return;
    }
    
    [JHNotificationManager notificationWithMessage:text];
}
-(void)notificationWithMessageTop:(NSString*)text
{
    [JHNotificationManager notificationWithMessageTop:text];
}
-(void)notificationHide
{
    [JHNotificationManager hideNotification];
}

-(void)ToastNotification:(NSString *)text
{
    [self notificationWithMessage:text];
}


//-(void)showNoticeViewIn:(UIViewController*)vc
//{
//    [[Manage_SystemNotice shareNotice] showNoticeIn:vc];
//}
//-(void)showNotice
//{
//    [[Manage_SystemNotice shareNotice] show];
//}
//-(void)hideNotice
//{
//    [[Manage_SystemNotice shareNotice] hide];
//}
@end

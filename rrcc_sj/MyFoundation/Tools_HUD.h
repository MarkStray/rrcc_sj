//
//  Tools_HUD.h
//  yuexiang
//
//  Created by kyl on 13-11-18.
//  Copyright (c) 2013年 kyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Tools_HUD : NSObject<MBProgressHUDDelegate>

+ (Tools_HUD*)shareTools_MBHUD;

//最终提示
-(void)notificationWithMessage:(NSString*)text inView:(UIView*)view delay:(CGFloat)delay;
-(void)notificationWithMessage:(NSString*)text;
-(void)notificationWithMessageTop:(NSString*)text;
-(void)notificationHide;
-(void)showBusying;
-(void)hideBusying;
//-(void)showChromeProgressBarInView:(UIView*)view withPoint:(CGPoint)point;
//-(void)hideChromeProgressBar;

//-(void)showNoticeViewIn:(UIViewController*)vc;
//-(void)showNotice;
//-(void)hideNotice;

-(void)alertTitle:(NSString *)str;
@end

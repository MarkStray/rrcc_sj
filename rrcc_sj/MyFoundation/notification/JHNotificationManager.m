//
//  NotificationManager.m
//  Notification
//
//  Created by Jeff Hodnett on 13/09/2011.
//  Copyright 2011 Applausible. All rights reserved.
//

static UIView *sView;
static CGFloat afterDelay;
static CGFloat posY;

#import "JHNotificationManager.h"

#define kSecondsVisibleDelay 3.0f
//#define kposY (44+ee_AppStatusHeight)
#define kposY 20
#define tposY 20

@implementation JHNotificationManager

+(JHNotificationManager *)sharedManager
{
    static JHNotificationManager *instance = nil;
    if(instance == nil) {
        instance = [[JHNotificationManager alloc] init];
    }
    return instance;
}

-(id)init
{
    if( (self = [super init]) ) {
        
        // Setup the array
        notificationQueue = [[NSMutableArray alloc] init];
        
        // Set not showing by default
        showingNotification = NO;
    }
    return self;
}

-(void)dealloc
{
    [notificationQueue release];
    
    [super dealloc];
}

#pragma messages
//+(void)notificationWithMessage:(NSString *)message
//{
//    // Show the notification
//    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
//}

+(void)notificationWithMessage:(NSString *)message
{
    afterDelay = kSecondsVisibleDelay;
    posY = kposY;
    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
}

+(void)notificationWithMessageTop:(NSString *)message
{
    afterDelay = kSecondsVisibleDelay;
    posY = tposY;
    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
}

+(void)notificationWithMessage:(NSString *)message inView:(UIView*)superView
{
    // Show the notification
    sView = superView;
    afterDelay = kSecondsVisibleDelay;
    posY = kposY;
    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
}

+(void)notificationWithMessage:(NSString *)message inView:(UIView*)superView delay:(CGFloat)delay
{
    sView = superView;
    afterDelay = delay;
    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
}


+(void)notificationWithMessage:(NSString *)message inView:(UIView*)superView posY:(CGFloat)posy
{
    sView = superView;
    afterDelay = kSecondsVisibleDelay;
    posY = posy;
    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
}
+(void)notificationWithMessage:(NSString *)message inView:(UIView*)superView delay:(CGFloat)delay posY:(CGFloat)posy
{
    sView = superView;
    afterDelay = delay;
    posY = posy;
    [[JHNotificationManager sharedManager] addNotificationViewWithMessage:message];
}

+(void)hideNotification
{
    [[JHNotificationManager sharedManager] onDismiss];
}

-(void)addNotificationViewWithMessage:(NSString *)message
{
    // Grab the main window
    
//    if (sView==nil) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        sView = window;
//    }
    // Grab the background image for calculations
    UIImage *bgImage = [UIImage imageNamed:@"notification_bg.png"];
    
    // Create the notification view (here you could just call another UIVirew subclass)
    UIView *notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, -bgImage.size.height, ee_AppSize.width, bgImage.size.height)];
    [notificationView setBackgroundColor:[UIColor clearColor]];
    
    // Add an image background
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ee_AppSize.width, bgImage.size.height)];
    [bgImageView setImage:bgImage];
    [notificationView addSubview:bgImageView];
    [bgImageView release];
    
    UIImage *info_icon = [UIImage imageNamed:@"notification_info_icon.png"];
    UIImageView *info_iconView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, info_icon.size.width, info_icon.size.height)];
    [info_iconView setImage:info_icon];
    [notificationView addSubview:info_iconView];
    [info_iconView release];
    
    UIImage *dismiss = [UIImage imageNamed:@"notification_dismiss_btn.png"];
    UIButton *dismissView = [[UIButton alloc] initWithFrame:CGRectMake(ee_AppSize.width-bgImage.size.height, 0, bgImage.size.height, bgImage.size.height)];
    [dismissView setImage:dismiss forState:UIControlStateNormal];
    [dismissView addTarget:self action:@selector(onDismiss) forControlEvents:UIControlEventTouchDown];
    [notificationView addSubview:dismissView];
    [dismissView release];
    
    // Add some text label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, notificationView.frame.size.height-10)];
    [label setText:message];
    [label setFont:[UIFont systemFontOfSize:12]];
    //[label setTextAlignment:UITextAlignmentLeft];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor colorWithRGBHex:color_info_blue]];
    [label setBackgroundColor:[UIColor clearColor]];
    [notificationView addSubview:label];
    [label release];
    
    
    UIView *clipView = [[UIView alloc] initWithFrame:CGRectMake(0, posY, ee_AppSize.width, bgImage.size.height)];
    [clipView setBackgroundColor:[UIColor clearColor]];
    clipView.clipsToBounds = YES;
    [clipView addSubview:notificationView];
    // Add to the window
    [sView addSubview:clipView];
    [notificationQueue addObject:clipView];
    [clipView release];
    [notificationView release];
    
    // Should we show this notification view
    if(!showingNotification) {
        [self showNotificationView:notificationView];
    }else{
        [self onDismiss];
    }
}

-(void)onDismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCurrentNotification) object:nil];
    if(showingNotification)
    [self hideCurrentNotification];
}

-(void)showNotificationView:(UIView *)notificationView
{
    // Set showing the notification
    showingNotification = YES;
    
    // Animate the view downwards
    [UIView beginAnimations:@"" context:nil];
    
    // Setup a callback for the animation ended
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showNotificationAnimationComplete:finished:context:)];
    
    [UIView setAnimationDuration:0.5f];
    
    [notificationView setFrame:CGRectMake(notificationView.frame.origin.x, notificationView.frame.origin.y+notificationView.frame.size.height, notificationView.frame.size.width, notificationView.frame.size.height)];
    
    [UIView commitAnimations];
}

-(void)showNotificationAnimationComplete:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    // Hide the notification after a set second delay
    [self performSelector:@selector(hideCurrentNotification) withObject:nil afterDelay:afterDelay];
}

-(void)hideCurrentNotification
{
    // Get the current view
    if ([notificationQueue count]==0) {
        return;
    }
    UIView *notificationView = [notificationQueue objectAtIndex:0];
    // Animate the view downwards
    [UIView beginAnimations:@"" context:nil];
    
    // Setup a callback for the animation ended
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideNotificationAnimationComplete:finished:context:)];
    
    [UIView setAnimationDuration:0.5f];
    
    UIView *notiView = (UIView*)(notificationView.subviews.lastObject);
    
    [notiView setFrame:CGRectMake(notiView.frame.origin.x, notiView.frame.origin.y-notiView.frame.size.height, notiView.frame.size.width, notiView.frame.size.height)];
    
    [UIView commitAnimations];
}

-(void)hideNotificationAnimationComplete:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    // Remove the old one
    if ([notificationQueue count]==0) {
        showingNotification = NO;
        return;
    }
    UIView *notificationView = [notificationQueue objectAtIndex:0];
    [notificationView removeFromSuperview];
    [notificationQueue removeObject:notificationView];
    
    // Set not showing
    showingNotification = NO;
    sView = nil;
    // Do we have to add anymore items - if so show them
    if([notificationQueue count] > 0) {
        UIView *v = [notificationQueue objectAtIndex:0];
        UIView *vsub = (UIView*)(v.subviews.lastObject);
        [self showNotificationView:vsub];
    }
}

@end

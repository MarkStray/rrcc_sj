//
//  LoginViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-19.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistMobileViewController.h"
#import "MainViewController.h"

@interface LoginViewController (){
    NSTimer *timer;
    NSInteger timeCount;
    __weak IBOutlet UITextField *TelText;
    __weak IBOutlet UITextField *PwdText;
    }
@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"登录";
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
 }


-(IBAction)Login:(id)sender{
    if (![TelText.text notEmptyOrNull]){
        
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入手机号"];
        return;
    }if (![Tools_Utils validateMobile:TelText.text]){
        
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入正确的手机号码!"];
    }
    if (![PwdText.text notEmptyOrNull]){
        
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入密码"];
    }
    UIDevice *device_=[[UIDevice alloc] init];
    NSString *DeviceInfo = [NSString stringWithFormat:@"%@%@%@%@%@",@"IOS:",device_.model,@"(",device_.systemVersion,@")"];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@%@",BASEURL,CustomerLogin,@"?account=",TelText.text];
    
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *loginUrl = [[RestHttpRequest SharHttpRequest] LoginPubKey:baseUrl InputResourceId:@"" InputPayLoad:@"" InPutPwd:PwdText.text];
    //配置参数
    NSDictionary *loginDic = [[NSDictionary alloc] initWithObjectsAndKeys:DeviceInfo,@"device",nil];
    [[AppDelegate Share].manger GET:loginUrl parameters:loginDic success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[userDic objectForJSONKey:@"Success"] isEqualToString:@"1"]){
            
            [[Tools_HUD shareTools_MBHUD] hideBusying];
            [[Utility Share] setUserId:[[userDic objectForJSONKey:@"CallInfo"]objectForJSONKey:@"userid"]];
            [[Utility Share] setPriviteKey:PwdText.text.md5];
            [[Utility Share] setUserAccount:TelText.text];
            [[Utility Share] setUserPwd:PwdText.text];
            [[Utility Share] saveUserInfoToDefault];
            //进入主界面
            MainViewController *MainView = [[MainViewController alloc] init];
            XHBaseNavigationController *mainNav = [[XHBaseNavigationController alloc] initWithRootViewController:MainView];
            mainNav.navigationBar.translucent = NO;
            [AppDelegate Share].window.rootViewController = mainNav;
        }else{
            [[Tools_HUD shareTools_MBHUD] alertTitle:@"密码错误,请重新登录!"];
            [[Tools_HUD shareTools_MBHUD] hideBusying];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        [[Tools_HUD shareTools_MBHUD] alertTitle:[error localizedDescription]];
        [[Tools_HUD shareTools_MBHUD]hideBusying];
    }];
}

-(IBAction)PushMobileView:(id)sender{
    RegistMobileViewController *RegistView = [[RegistMobileViewController alloc] init];
    [self pushNewViewController:RegistView];
}


-(void)closeKeyBoard{
    [TelText resignFirstResponder];
    [PwdText resignFirstResponder];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end

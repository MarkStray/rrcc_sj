//
//  ChangeUserInfoViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "ChangeUserInfoViewController.h"

@interface ChangeUserInfoViewController ()
{
    __weak IBOutlet UITextField *UserNameText;
    __weak IBOutlet UITextField *TelText;
    __weak IBOutlet UITextField *CaptchaText;
    __weak IBOutlet UIButton *CaptchButt;
    
}

@end

@implementation ChangeUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改联系信息";
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
}

-(IBAction)OnGetCaptch:(id)sender
{
    UIDevice *device_=[[UIDevice alloc] init];
    NSString *DeviceInfo = [NSString stringWithFormat:@"%@%@%@%@%@",@"IOS:",device_.model,@"(",device_.systemVersion,@")"];
    NSDictionary *CaptchDic = [[NSDictionary alloc] initWithObjectsAndKeys:TelText.text,@"mobile", DeviceInfo,@"device",nil];
    
    
    NSString *CpatchaUrl = [NSString stringWithFormat:@"%@%@",BASEURL,Captcha];
    [[AppDelegate Share].manger  POST:CpatchaUrl parameters:CaptchDic success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
    NSDictionary *CaptchDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
     DLog(@"是%@",CaptchDic);
    if ([[CaptchDic objectForJSONKey:@"Success"] isEqualToString:@"1"])
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"验证码已发送,请注意查收!"];
    }
    else
    {
        [[Tools_HUD shareTools_MBHUD]alertTitle:[CaptchDic objectForKey:@"ErrorMsg"]];
    }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
     }];
}



-(IBAction)Submit:(id)sender
{
    
    NSString *payload = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"name=",UserNameText,@"&mobile=",TelText.text,@"&captcha=",CaptchaText.text];
    NSString *baseurl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopContact,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *strpayload = [[Utility Share] base64Encode:payload];
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:strpayload];
    DLog(@"url 是%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:strpayload];
    //发送网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    [request setHTTPMethod:@"put"];
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"JSON responseObject: %@ ",responseObject);
         if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"])
         {
             //刷新表
         }
         else
         {
             [[ Tools_HUD shareTools_MBHUD] alertTitle:[responseObject objectForJSONKey:@"ErrorMsg"]];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", [error localizedDescription]);
     }];
    [op start];
}


#pragma mark 关闭键盘 
-(void)closeKeyBoard
{
    [UserNameText resignFirstResponder];
    [TelText resignFirstResponder];
    [CaptchaText resignFirstResponder];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

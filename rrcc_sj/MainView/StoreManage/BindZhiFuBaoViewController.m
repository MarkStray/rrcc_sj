//
//  BindZhiFuBaoViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "BindZhiFuBaoViewController.h"

@interface BindZhiFuBaoViewController ()
{
    __weak IBOutlet UITextField *AliPayText;
}

@end

@implementation BindZhiFuBaoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"支付宝绑定";
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
}



-(IBAction)SaveAiLipayCount:(UIButton*)sender
{
    NSString *PayLoadStr = [NSString stringWithFormat:@"%@%@",@"account=",AliPayText.text];
    NSString *StrPayLoad = [[Utility Share] base64Encode:PayLoadStr];
    NSString *BaseUrl    = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,CustomerAlipay,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *UrlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:BaseUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:StrPayLoad];
    //
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:StrPayLoad];
    NSURL *url = [NSURL URLWithString:UrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                        cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"])
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"您的支付宝账号已绑定成功!"];
             [[Utility Share] setAiLiPayCountStr:AliPayText.text];
             [[Utility Share] saveUserInfoToDefault];
             [self closeKeyBoard];
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
            [[Tools_HUD shareTools_MBHUD] alertTitle:@"绑定失败,请重新添加"];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", [error localizedDescription]);
     }];
    [op start];

}


-(void)closeKeyBoard
{

    [AliPayText resignFirstResponder];
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

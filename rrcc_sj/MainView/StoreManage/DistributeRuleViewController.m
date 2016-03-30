//
//  DistributeRuleViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "DistributeRuleViewController.h"

@interface DistributeRuleViewController ()
{
    __weak IBOutlet UITextField *RuleText;
}

@end

@implementation DistributeRuleViewController


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self GetStorInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"配送规则";
    
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
    
}

#pragma mark 提交规则信息
-(IBAction)SubmitRuleInfo:(id)sender
{
    NSString *PriceStr = RuleText.text;
    
    if ([RuleText.text isEqualToString:@""])
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入起订标准!"];
    }
    else if ([PriceStr integerValue] >100)
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"起订标准不能大于100元!"];
    }
    else
    {

    NSString *payLoadStr = [[Utility Share] base64Encode: [NSString stringWithFormat:@"%@%@%@%@%@",@"mini=",RuleText.text,@"&free=",RuleText.text,@"&cost=0"]];
        
    NSString *RuleUrl   = [NSString stringWithFormat:@"%@%@",BASEURL,ShopDeliveryRule];
    NSString *UrlStr = [[RestHttpRequest SharHttpRequest] AppendPublickKey:RuleUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:payLoadStr];
    NSURL *url = [NSURL URLWithString:UrlStr];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:payLoadStr];
    //发送网络请求
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
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"修改成功!"];
             [self GetStorInfo];
         }
         else
         {
            [[ Tools_HUD shareTools_MBHUD] alertTitle:@"修改失败!"];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", [error localizedDescription]);
     }];
    [op start];
    }
  
}

-(void)GetStorInfo
{
    
    NSString *StoreUrl = [NSString stringWithFormat:@"%@%@",BASEURL,CustomerShopList];
    NSString *strUrl = [[RestHttpRequest SharHttpRequest] AppendPublickKey:StoreUrl InputResourceId:[[Utility Share] userId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"])
         {
  
             //处理店铺信息，判断是否为空
             NSString *AdressStr = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"address"];
             NSString *Amount    = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"amount"];
             NSString *CloseTime = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"closetime"];
             NSString *StartTime = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"starttime"];
             NSString *StoreId   = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"id"];
             NSString *IsOpen    = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"isopen"];
             NSString *ShopName  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"shop_name"];
             NSString *SiteList  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"sitelist"];
             NSString *Status  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"status"];
             NSString  *deliverycost = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"deliverycost"];
             NSString *freedelivery = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"freedelivery"];
             NSString *minorder  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"minorder"];
             if (![SiteList notEmptyOrNull])
             {
                 SiteList = @"";
             }
             NSMutableDictionary *StoreDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:AdressStr,@"address",Amount,@"amount",CloseTime,@"closetime",StartTime,@"starttime",StoreId,@"id",IsOpen,@"isopen",ShopName,@"shop_name",SiteList,@"sitelist",Status,@"status",deliverycost,@"deliverycost",freedelivery,@"freedelivery",minorder,@"minorder",nil];
             [[Utility Share] setStoreDic:StoreDic];
             [[Utility Share] setStoreId:Dic[@"CallInfo"][0][@"id"]];
             [[Utility Share] setOpenStatus:Dic[@"CallInfo"][0][@"isopen"]];
             [[Utility Share] saveUserInfoToDefault];
             [self.navigationController popViewControllerAnimated:YES];
             
         }
         else
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:[Dic objectForJSONKey:@"ErrorMsg"]];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}





-(void)closeKeyBoard
{
    [RuleText resignFirstResponder];
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

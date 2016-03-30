//
//  ChangeAdressViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "ChangeAdressViewController.h"
#import "GetCityListViewController.h"

@interface ChangeAdressViewController ()
{
    __weak IBOutlet UILabel *CityLb;
    __weak IBOutlet UITextView *DetailAdresstext;
    NSDictionary *CityDic;
}

@end

@implementation ChangeAdressViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改地址";
    [[Utility Share] readUserInfoFromDefault];
    
    
    CityLb.userInteractionEnabled = YES;
    NSString *regionStr = [[[Utility Share] storeDic] objectForJSONKey:@"regionname"];
    if (regionStr.length == 0)
    {
         CityLb.text = @"请选择省市区";
    }
    else
    {
    CityLb.text = [[[Utility Share] storeDic] objectForJSONKey:@"regionname"];
    }
    DetailAdresstext.text = [[[Utility Share] storeDic] objectForJSONKey:@"address"];
    UIGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(GoToCityList:)];
    [CityLb addGestureRecognizer:tapLabel];
    [CityLb setUserInteractionEnabled:YES];
    
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetCityList:) name:@"CityName" object:nil];
}


-(void)GoToCityList:(id)sender
{
     GetCityListViewController *CityView = [[GetCityListViewController alloc] init];
    [self pushNewViewController:CityView];
}

-(void)GetCityList:(NSNotification*)text
{
    CityDic = [[NSDictionary alloc] init];
    CityDic = text.userInfo;
    CityLb.text = [NSString stringWithFormat:@"%@%@",[CityDic objectForJSONKey:@"ProvinceName"],[CityDic objectForJSONKey:@"RegionName"]];
}

-(IBAction)SubmitAdress:(id)sender
{
    NSString *provinceId;
    NSString *CityId;
    if (CityDic == nil)
    {
        provinceId = [NSString stringWithFormat:@"%@%@%@",@"privinceId=",[[[Utility Share]storeDic] objectForJSONKey:@"provinceid"],@"&"];
        
        CityId     = [NSString stringWithFormat:@"%@%@",@"cityId=",[[[Utility Share]storeDic] objectForJSONKey:@"regionid"]];
    }
    else
    {
        provinceId = [NSString stringWithFormat:@"%@%@%@",@"privinceId=",[CityDic objectForJSONKey:@"Parentid"],@"&"];
        CityId   = [NSString stringWithFormat:@"%@%@",@"cityId=",[CityDic objectForJSONKey:@"id"]];
    }
    NSString *AdressStr  = [NSString stringWithFormat:@"%@%@%@",@"address=",DetailAdresstext.text,@"&"];
    NSString *PladStr =  [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",AdressStr,provinceId,CityId]]; //取Base64
    //获得URl
    NSString *AdresUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopAddress,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *StrUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:AdresUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:PladStr];
    NSURL *url = [NSURL URLWithString:StrUrl];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:PladStr];
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
             [[Tools_HUD shareTools_MBHUD ]alertTitle:@"修改地址成功!"];
             [self GetStorInfo];
         }
         else
         {
             [[ Tools_HUD shareTools_MBHUD] alertTitle:@"修改失败"];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", [error localizedDescription]);
     }];
    [op start];
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
    [DetailAdresstext resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

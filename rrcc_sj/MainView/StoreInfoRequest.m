//
//  StoreInfoRequest.m
//  rrcc_sj
//
//  Created by lawwilte on 7/28/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import "StoreInfoRequest.h"
#import "LoginViewController.h"
@implementation StoreInfoRequest

//单例
+(StoreInfoRequest*)Share{
    static StoreInfoRequest *instance = nil;
    @synchronized(self){
    if (!instance){
        instance = [[StoreInfoRequest alloc] init];
      }
    }
    return instance;
}

-(void)GetStoreInfo{
    NSString *StoreUrl = [NSString stringWithFormat:@"%@%@",BASEURL,CustomerShopList];
    NSString *strUrl = [[RestHttpRequest SharHttpRequest] AppendPublickKey:StoreUrl InputResourceId:[[Utility Share] userId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *  operation, id  responseObject){
    NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
    if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"]){
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
        NSString *deliverycost = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"deliverycost"];
        NSString *freedelivery = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"freedelivery"];
        NSString *minorder  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"minorder"];
        NSString *provinceid = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"provinceid"];
        NSString *regionid   = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"regionid"];
        NSString *regionname = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"regionname"];
        if (![SiteList notEmptyOrNull]){
                SiteList = @"";
           }
        NSMutableDictionary *StoreDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:AdressStr,@"address",Amount,@"amount",CloseTime,@"closetime",StartTime,@"starttime",StoreId,@"id",IsOpen,@"isopen",ShopName,@"shop_name",SiteList,@"sitelist",Status,@"status",deliverycost,@"deliverycost",freedelivery,@"freedelivery",minorder,@"minorder",provinceid,@"provinceid",regionid,@"regionid",regionname,@"regionname",nil];
        [[Utility Share] setStoreDic:StoreDic];
        [[Utility Share] setStoreId:Dic[@"CallInfo"][0][@"id"]];
        [[Utility Share] setOpenStatus:Dic[@"CallInfo"][0][@"isopen"]];
        [[Utility Share] saveUserInfoToDefault];
        }else{
        //清空用户数据
        [[Utility Share] clearUserInfoInDefault];
        //进入登录
        LoginViewController*LoginView = [[LoginViewController alloc] init];
        XHBaseNavigationController *LoginNav = [[XHBaseNavigationController alloc] initWithRootViewController:LoginView];
        LoginNav.navigationBar.translucent = NO;
            [AppDelegate Share].window.rootViewController = LoginNav;
        }
    }failure:^(AFHTTPRequestOperation *  operation, NSError *  error){
        
    }];
}
@end

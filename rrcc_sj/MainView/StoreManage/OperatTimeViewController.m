//
//  OperatTimeViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "OperatTimeViewController.h"
#import "IQActionSheetPickerView.h"


BOOL MondBool = YES;

@interface OperatTimeViewController ()<IQActionSheetPickerViewDelegate>
{
    __weak IBOutlet UIButton *StartTimeButt;//开始时间
    __weak IBOutlet UIButton *EndTimeButt;//结束时间
    NSMutableArray  *DaysArray;//日期
    NSMutableArray  *WorkDaysArray;//营业日期
    __weak IBOutlet UIButton *MondayButt;
    __weak IBOutlet UIButton *TuesdayButt;
    __weak IBOutlet UIButton *WednesdayButt;
    __weak IBOutlet UIButton *ThursdayButt;
    __weak IBOutlet UIButton *FridayButt;
    __weak IBOutlet UIButton *StaurdayButt;
    __weak IBOutlet UIButton *sundayButt;
    

    
    NSString *MonStr;//星期一
    NSString *TuesStr;//星期二
    NSString *WedStr;//星期三;
    NSString *ThuStr;//星期四
    NSString *FriStr;//星期五
    NSString *StauStr;//星期六
    NSString *SunStr;//星期日;
    
    
}
@end

@implementation OperatTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [StartTimeButt setTitle:[[[Utility Share] storeDic] objectForJSONKey:@"starttime"] forState:UIControlStateNormal];
    [EndTimeButt setTitle:[[[Utility Share] storeDic] objectForJSONKey:@"closetime"] forState:UIControlStateNormal];
    self.title = @"修改营业时间";
}

#pragma mark 时间选择
-(IBAction)SelectTime:(UIButton *)sender
{
    
    NSInteger tag = [sender tag];
    IQActionSheetPickerView *picker =  [[IQActionSheetPickerView alloc] initWithTitle:@"时间选择" delegate:self];
       if (tag == 1)
    {
        [picker setTag:1];
        [picker setTitlesForComponenets:@[@[@"0:00", @"1:00", @"2:00", @"3:00", @"4:00",@"5:00",@"6:00",@"7:00",@"8:00",@"9:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00"]]];
        
        [picker show];
    }
    if (tag == 2)
    {
        [picker setTag:2];
        [picker setTitlesForComponenets:@[@[@"0:00", @"1:00", @"2:00", @"3:00", @"4:00",@"5:00",@"6:00",@"7:00",@"8:00",@"9:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00"]]];

        [picker show];
    }
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    
    if (pickerView.tag == 1)
    {
        
        [StartTimeButt setTitle:[titles componentsJoinedByString:@" - "] forState:UIControlStateNormal];
    }
    if (pickerView.tag == 2)
    {
    
         [EndTimeButt setTitle:[titles componentsJoinedByString:@" - "] forState:UIControlStateNormal];
    }
    
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (pickerView.tag == 1)
    {
        [StartTimeButt setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];

    }
    if (pickerView.tag == 2)
    {
        [EndTimeButt setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];

    }
    
    
    
    
    /*
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (pickerView.tag == 1)
    {
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [StartTimeButt setTitle:TimeStr forState:UIControlStateNormal];
    }
    if (pickerView.tag == 2)
    {
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [EndTimeButt setTitle:TimeStr forState:UIControlStateNormal];
    }
     */
}


-(IBAction)Submit:(id)sender
{
    
        NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopOpeningDatetime,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
        NSString *PayLoadStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"start=",StartTimeButt.titleLabel.text,@"&end=",EndTimeButt.titleLabel.text,@"&workday=",@"YYYYYYY"];
        NSString *StrPayload = [[Utility Share] base64Encode:PayLoadStr];
        NSString *urlStr  = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:StrPayload];
        NSURL *url = [NSURL URLWithString:urlStr];
        //获得HTTP Body
        NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:StrPayload];
        //发送网络请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                   cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        [request setHTTPMethod:@"PUT"];
        [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             DLog(@"返回的数据是%@",responseObject);
             if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"])
             {
                 //刷新表
                 [[Tools_HUD shareTools_MBHUD] alertTitle:@"修改成功!"];
                 [self GetStorInfo];
//                 [[Utility Share] GetStoreInfo];
//               //  sleep(1.5);
//                 
//                 NSDictionary *DIC = [[Utility Share] storeDic];
//                 DLog(@"Dic 是%@",DIC);
//                 [self.navigationController popViewControllerAnimated:YES];
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



-(void)GetStorInfo
{
    
    NSString *StoreUrl = [NSString stringWithFormat:@"%@%@",BASEURL,CustomerShopList];

    NSString *strUrl = [[RestHttpRequest SharHttpRequest] AppendPublickKey:StoreUrl InputResourceId:[[Utility Share] userId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         DLog(@"dic 是%@",Dic);
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
             DLog(@"StoreDic 是%@",StoreDic);
             [[Utility Share] setStoreDic:StoreDic];
             [[Utility Share] setStoreId:Dic[@"CallInfo"][0][@"id"]];
             [[Utility Share] setOpenStatus:Dic[@"CallInfo"][0][@"isopen"]];
             [[Utility Share] saveUserInfoToDefault];
             [self.navigationController popViewControllerAnimated:YES];
             DLog(@"Dic是%@",[[Utility Share] storeDic]);

         }
         else
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:[Dic objectForJSONKey:@"ErrorMsg"]];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

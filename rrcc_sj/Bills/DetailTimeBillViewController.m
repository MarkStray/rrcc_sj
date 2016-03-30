//
//  DetailTimeBillViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "DetailTimeBillViewController.h"

@interface DetailTimeBillViewController ()
{
    NSMutableArray *Counarray;
    NSMutableArray *TodayOrderArray;//今日订单
    NSMutableArray *TodayPriceArray;//今日价格数
    NSMutableArray *ActurOrdersArray;//应结算订单
    NSMutableArray *ActurPriceArray;//应结算价格数
    NSMutableArray *DoneOrdersArray;//已结算订单
    NSMutableArray *DonePriceArray;//已结算的价格
    
    
    __weak IBOutlet UILabel *AllTimeLb;
    __weak IBOutlet UILabel *TodayOrderLb;//今日订单
    __weak IBOutlet UILabel *ActOrderLb;//应结算订单
    __weak IBOutlet UILabel *PromOrderLb;//促销补贴
    __weak IBOutlet UILabel *DoneOrderLb;//已结算订单
}

@end

@implementation DetailTimeBillViewController
@synthesize DetailDic;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的账单";
    NSString   *start = [DetailDic objectForJSONKey:@"start"];
    NSString   *end   = [DetailDic objectForJSONKey:@"end"];
    AllTimeLb.text = [NSString stringWithFormat:@"%@%@%@",start,@"-",end];
    [self GetBillInfo];
}




-(void)GetBillInfo
{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    //设置时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *EndTime = [formatter stringFromDate:[NSDate date]];
    
    //获取前天,使用日历类
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *Comps;
    Comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
    [Comps setHour:-48]; //+24表示获取下一天的date，-24表示获取前一天的date；
    [Comps setMinute:0];
    [Comps setSecond:0];
    NSDate *nowDate = [calendar dateByAddingComponents:Comps toDate:[NSDate date] options:0];
    NSString *StartTime  = [[NSString stringWithFormat:@"%@",nowDate] substringWithRange:NSMakeRange(0, 10)];
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",BASEURL,ShopBillList,[[Utility Share]storeId],@"?uid=",[[Utility Share] userId],@"&start=",StartTime,@"&end=",EndTime];
    
    NSString *UrlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:url InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    
    TodayOrderArray =[NSMutableArray array];
    [[AppDelegate Share].manger GET:UrlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if ([[Dic objectForJSONKey:@"Success"] isEqualToString:@"1"])
         {
             
       
         NSMutableArray *array  = Dic[@"CallInfo"];
         for (int i=0;i<array.count;i++)
         {
            id order = [[array objectAtIndex:i] objectForJSONKey:@"total_order"] ;
             [TodayOrderArray addObject:order];
        }
          //数组求和
      NSString *sum = [TodayOrderArray valueForKeyPath:@"@sum.floatValue"];
         DLog(@"%@",sum);
      TodayOrderLb.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",sum,@"单",@"/",sum,@"元"];
      ActOrderLb.text   = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",sum,@"单",@"/",sum,@"元"];
      PromOrderLb.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",sum,@"单",@"/",sum,@"元"];
      DoneOrderLb.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",sum,@"单",@"/",sum,@"元"];
        }
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
}



- (void)didReceiveMemoryWarning
{
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

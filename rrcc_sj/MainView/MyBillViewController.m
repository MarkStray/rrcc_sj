//
//  MyBillViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-20.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "MyBillViewController.h"
#import "SelectTimeViewController.h"

@interface MyBillViewController ()
{
    __weak IBOutlet UILabel *TodayOrderLb;//今日订单
    __weak IBOutlet UILabel *CompledOrderLb;//应结算订单
    __weak IBOutlet UILabel *PromotionLb;//促销补贴
    __weak IBOutlet UILabel *ClearingLb;//已结算订单
}
@property (weak, nonatomic) IBOutlet UILabel *TimeLb;

@end

@implementation MyBillViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的账单";
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    _TimeLb.text = currentTime;
    _TimeLb.userInteractionEnabled = YES;
    UIGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ShowSelectTimeBillInfo)];
    [_TimeLb addGestureRecognizer:tapLabel];
    [_TimeLb setUserInteractionEnabled:YES];
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
    [[AppDelegate Share].manger GET:UrlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"])
        {
         NSArray *OrderArray = Dic[@"CallInfo"];
        if (OrderArray.count >0 )
        {
        NSDictionary *OrderDic = Dic[@"CallInfo"][0];
        TodayOrderLb.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",OrderDic[@"total_order"],@"单",@"/",OrderDic[@"total_amount"],@"元"];
        CompledOrderLb.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",OrderDic[@"total_order"],@"单",@"/",OrderDic[@"total_amount"],@"元"];
        PromotionLb.text     = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",OrderDic[@"total_order"],@"单",@"/",OrderDic[@"total_amount"],@"元"];
        ClearingLb.text     =  [NSString stringWithFormat:@"%@%@%@%@%@%@",@"共:",OrderDic[@"total_order"],@"单",@"/",OrderDic[@"total_amount"],@"元"];
        }
            
        [[Tools_HUD shareTools_MBHUD] hideBusying];
    }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [[Tools_HUD shareTools_MBHUD] hideBusying];
    }];
}

-(void)ShowSelectTimeBillInfo
{
    
    SelectTimeViewController *selectTimeView = [[SelectTimeViewController alloc] init];
    [self pushNewViewController:selectTimeView];
   // [self pushController:[SelectTimeViewController class] withInfo:nil withTitle:@"我的账单"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end

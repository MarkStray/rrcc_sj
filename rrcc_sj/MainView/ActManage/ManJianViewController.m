//
//  ManJianViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "ManJianViewController.h"
#import "ManJianTableViewCell.h"
#import "AddActViewController.h"

@interface ManJianViewController ()
{
    NSMutableArray *ManJianArray;
}
@property (weak, nonatomic) IBOutlet UITableView *ManJianTable;

@end

@implementation ManJianViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self GetManJianInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"满减活动";
    ManJianArray = [NSMutableArray array];
    _ManJianTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self GetManJianInfo];
}


-(void)GetManJianInfo{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *StrURl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopDiscountList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *EndUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:StrURl InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:EndUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        ManJianArray = Dic[@"CallInfo"];
        [_ManJianTable reloadData];
        [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
}

-(void)DeleteDiscount:(NSString*)StrId{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopDiscount,StrId,@"?uid=",[[Utility Share] userId]];
    NSString *endUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:strUrl InputResourceId:StrId InputPayLoad:@"" ];
    [[AppDelegate Share] .manger DELETE:endUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[Dic objectForJSONKey:@"Success"] isEqualToString:@"1"]){
            [[Tools_HUD shareTools_MBHUD] alertTitle:@"删除成功!"];
            [self GetManJianInfo];
        }
        [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ManJianArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    static NSString *Identifier = @"Identifier";
    ManJianTableViewCell *ManJianCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (ManJianCell == nil)
    {
        ManJianCell = [[[NSBundle mainBundle] loadNibNamed:@"ManJianTableViewCell" owner:self options:nil] lastObject];
        ManJianCell.CellbackView.backgroundColor = RGBCOLOR(242, 242, 242);
        ManJianCell.ActDesLb.textColor = RGBCOLOR(69, 171, 222);
        //写反了
        NSString *DiscountStr = [[ManJianArray objectAtIndex:index] objectForJSONKey:@"limit"];
        NSString *limitStr   = [[ManJianArray objectAtIndex:index] objectForJSONKey:@"discount"];
        ManJianCell.ActDesLb.text =  [NSString stringWithFormat:@"%@%@%@%@",@"单笔订单满",DiscountStr,@"减",limitStr];
        
        NSInteger Num = [[[ManJianArray objectAtIndex:index] objectForJSONKey:@"num"] integerValue];
        ManJianCell.NumberLb.text = [[ManJianArray objectAtIndex:index] objectForJSONKey:@"num"];
        
        NSString *startTime = [[ManJianArray objectAtIndex:index] objectForJSONKey:@"start"];
        NSString *endTime   = [[ManJianArray objectAtIndex:index] objectForJSONKey:@"expired"];
        ManJianCell.ActTimeLb.text = [NSString stringWithFormat:@"%@%@%@",startTime,@"到",endTime];
        ManJianCell.ActTimeLb.textColor = [UIColor lightGrayColor];
        ManJianCell.TypeLb.textColor    = [UIColor lightGrayColor];
        
        
        //时间比较
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        NSInteger nowTime  = [currentTime integerValue];

        NSInteger start = [[startTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        NSInteger end   = [[endTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        if (nowTime >= start &&  nowTime <= end  && Num>0)
        {
            ManJianCell.TypeLb.text = @"进行中";
        }
        else
        {
            ManJianCell.TypeLb.text  = @"已结束";
        }
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(10,70, kScreenWidth-20,10)];
        cellView.backgroundColor = [UIColor clearColor];
        [ManJianCell addSubview:cellView];
    }
    ManJianCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return ManJianCell;
}
#pragma mark TableView Delegate
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSString *Strid = [[ManJianArray objectAtIndex:index] objectForJSONKey:@"id"];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self DeleteDiscount:Strid];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
       
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}

-(IBAction)AddActView:(id)sender
{
    AddActViewController *AddActView = [[AddActViewController alloc] init];
    [self pushNewViewController:AddActView];
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

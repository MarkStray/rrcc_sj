//
//  ZenPinViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "ZenPinViewController.h"
#import "ZenPinTableViewCell.h"
#import "AddZenPinViewController.h"
@interface ZenPinViewController ()
{
    NSMutableArray *GiftArray;
}
@property (weak, nonatomic) IBOutlet UITableView *ZenPintable;
@end
@implementation ZenPinViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self GetZenPinList];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"赠品活动";
    _ZenPintable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self GetZenPinList];
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.ZenPintable setEditing:NO];
}

#pragma mark 获得赠品管理列表

-(void)GetZenPinList
{
    
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *StrURl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopGiftList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *EndUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:StrURl InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:EndUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        GiftArray = Dic[@"CallInfo"];
        [_ZenPintable reloadData];
        [[Tools_HUD shareTools_MBHUD] hideBusying];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[Tools_HUD shareTools_MBHUD]hideBusying];
     }];
}

//删除赠品信息
-(void)DeleteGift:(NSString*)StrId
{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopGift,StrId,@"?uid=",[[Utility Share] userId]];
    NSString *endUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:strUrl InputResourceId:StrId InputPayLoad:@""];
    [[AppDelegate Share] .manger DELETE:endUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if ([[userDic objectForJSONKey:@"Success"]isEqualToString:@"1"])
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"删除成功!"];
             [self GetZenPinList];
         }
         [[Tools_HUD shareTools_MBHUD]hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    
}



-(IBAction)AddZenPinInfo:(id)sender
{
    AddZenPinViewController *ZenPinView = [[AddZenPinViewController alloc] init];
    [self pushNewViewController:ZenPinView];

}




#pragma mark UItabelVeiw delegate && datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return GiftArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    static NSString *Identifier = @"Identifier";
    ZenPinTableViewCell *ZenPinCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (ZenPinCell == nil)
    {
        ZenPinCell = [[[NSBundle mainBundle] loadNibNamed:@"ZenPinTableViewCell" owner:self options:nil] lastObject];
        ZenPinCell.CellbackView.backgroundColor = RGBCOLOR(242, 242, 242);
        ZenPinCell.ActDesLb.textColor = RGBCOLOR(69, 171, 222);
        ZenPinCell.TypeLb.textColor   = [UIColor lightGrayColor];
        ZenPinCell.ActTimeLb.textColor = [UIColor lightGrayColor];
        ZenPinCell.ActDesLb.text = [[GiftArray objectAtIndex:index] objectForJSONKey:@"gift"];
        
        NSString *startTime = [[GiftArray objectAtIndex:index] objectForJSONKey:@"start"];
        NSString *endTime   = [[GiftArray objectAtIndex:index] objectForJSONKey:@"expired"];
        ZenPinCell.ActTimeLb.text = [NSString stringWithFormat:@"%@%@%@",startTime,@"到",endTime];
        NSInteger num  = [[[GiftArray objectAtIndex:index] objectForJSONKey:@"num"] integerValue];
        ZenPinCell.NumLb.text   = [NSString stringWithFormat:@"%@",[[GiftArray objectAtIndex:index] objectForJSONKey:@"num"]];

        //时间比较
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        NSInteger nowTime  = [currentTime integerValue];
        
        NSInteger start = [[startTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        NSInteger end   = [[endTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        
        ZenPinCell.textLabel.textColor = [UIColor lightGrayColor];
        if (nowTime >= start &&  nowTime <= end && num >0){
            ZenPinCell.TypeLb.text = @"进行中";
        }else{
            ZenPinCell.TypeLb.text  = @"已结束";
        }
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(10,70, kScreenWidth-20,10)];
        cellView.backgroundColor = [UIColor clearColor];
        [ZenPinCell addSubview:cellView];
    }
    ZenPinCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return ZenPinCell;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSString *Strid = [[GiftArray objectAtIndex:index] objectForJSONKey:@"id"];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        [self DeleteGift:Strid];
        
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

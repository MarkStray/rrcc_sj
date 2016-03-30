//
//  CuXiaoActViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "CuXiaoActViewController.h"
#import "CuXiaoTableViewCell.h"
#import "StockMgViewController.h"

@interface CuXiaoActViewController ()
{
    
    NSMutableArray *PromArray;
    
    __weak IBOutlet UITableView *CuXiaotable;
}

@end

@implementation CuXiaoActViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self GetProminfo];
    UIView *view  = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    CuXiaotable.tableFooterView = view;
    self.title = @"促销活动";
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [CuXiaotable setEditing:NO];
}


#pragma mark 获得促销信息
-(void)GetProminfo
{
    
    NSString *StrURl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopSaleList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *EndUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:StrURl InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:EndUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         DLog(@"UserDic 是%@",userDic);
         PromArray = userDic[@"CallInfo"];
        [CuXiaotable reloadData];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
     }];
}

-(void)DeletePromInfo:(NSString*)StrId
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopSale,StrId,@"?uid=",[[Utility Share] userId]];
    NSString *endUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:strUrl InputResourceId:StrId InputPayLoad:@"" ];
    DLog(@"endUrl 是 %@",endUrl);
    [[AppDelegate Share] .manger DELETE:endUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if ([[userDic objectForJSONKey:@"Success"] isEqualToString:@"1"])
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"删除成功!"];
             [self GetProminfo];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"网络请求错误,请重新获取!"];
    }];
}


#pragma mark TableViewDelegate && DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PromArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    static NSString *Identifier = @"Identifier";
    CuXiaoTableViewCell *CuXiaoCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (CuXiaoCell == nil)
    {
        CuXiaoCell = [[[NSBundle mainBundle] loadNibNamed:@"CuXiaoTableViewCell" owner:self options:nil] lastObject];
    }
    CuXiaoCell.SkuNameLb.text = [[PromArray objectAtIndex:index] objectForJSONKey:@"skuname"];
    CuXiaoCell.SalePriceLb.text = [[PromArray objectAtIndex:index] objectForJSONKey:@"saleprice"];
    NSString *StrProce = [[PromArray objectAtIndex:index] objectForJSONKey:@"price"];
    NSString *StrMount = [[PromArray objectAtIndex:index] objectForJSONKey:@"saleamount"];
    CuXiaoCell.NowPriceLb.text  = [NSString stringWithFormat:@"%@%@%@%@%@",@"现价:",@"￥",StrProce,@"库存:",StrMount];
    CuXiaoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return CuXiaoCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSString *Strid = [[PromArray objectAtIndex:index] objectForJSONKey:@"id"];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
       [self DeletePromInfo:Strid];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
    
    
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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

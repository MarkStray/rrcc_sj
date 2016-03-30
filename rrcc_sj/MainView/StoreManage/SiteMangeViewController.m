//
//  SiteMangeViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-6-10.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "SiteMangeViewController.h"
#import "CustomTableViewCell.h"
#import "AddSiteAreaViewController.h"

@interface SiteMangeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *SiteTable;
    NSMutableArray  *SiteListArray;
    NSMutableArray  *Contacts;
    NSMutableArray  *SiteIdArray;

}

@end

@implementation SiteMangeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self GetShopDeliverySiteList];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"小区管理";
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [SiteTable setTableFooterView:view];
    SiteListArray =[NSMutableArray array];
    Contacts      =[NSMutableArray array];
    SiteIdArray   =[NSMutableArray array];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SiteListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSDictionary *Celldic = [SiteListArray objectAtIndex:index];
    NSString *Identifier = Celldic.description.md5;
    CustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        UILabel *SiteNameLb = [RHMethods labelWithFrame:CGRectMake(15,12.5,150,20) font:Font(15.0f)color:[UIColor darkGrayColor] text:[[SiteListArray objectAtIndex:index] objectForJSONKey:@"name"]];
        
        UILabel *DistanceLb = [RHMethods labelWithFrame:CGRectMake(XW(SiteNameLb),Y(SiteNameLb),80,20) font:Font(15.0f) color:[UIColor darkGrayColor] text:[NSString stringWithFormat:@"%@%@%@",@"距离",[[SiteListArray objectAtIndex:index] objectForJSONKey:@"distance"],@"km"]];
        
        
        UILabel *DistribLb = [RHMethods labelWithFrame:CGRectMake(XW(cell.m_checkImageView)+5, 12.5,30, 20) font:Font(15.0f) color:[UIColor darkGrayColor] text:@"配送"];
        [cell addSubview:DistribLb];
        [cell addSubview:SiteNameLb];
        [cell addSubview:DistanceLb];
        
        
//        //根据SiteListArray为Contacts 添加数据
//        for (int i = 0; i <SiteListArray.count; i++)
//        {
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            [dic setValue:@"NO" forKey:@"checked"];
//            [Contacts addObject:dic];
//        }
// 
        if ([[[SiteListArray objectAtIndex:index] objectForJSONKey:@"isused"] isEqualToString:@"1"])
        {
            NSMutableDictionary *dic = [Contacts objectAtIndex:index];
            [dic setObject:@"YES" forKey:@"checked"];
            [cell setChecked:YES];
        }
        else
        {
           NSMutableDictionary *dic = [Contacts objectAtIndex:index];
           [dic setObject:@"NO" forKey:@"checked"];
           [cell setChecked:NO];
        }
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger index = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 获取点击的cell
    CustomTableViewCell *cell = (CustomTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    // 获取点击cell的标识
    NSMutableDictionary *dic = [Contacts objectAtIndex:index];
    
    // 如何是选中改成未选中，如果是为选中改成选中
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"])
    {
        [dic setObject:@"YES" forKey:@"checked"];
        [cell setChecked:YES];
        NSString *StrID = [[SiteListArray objectAtIndex:index] objectForJSONKey:@"id"];
        [SiteIdArray addObject:StrID];
    }else
    {
        [dic setObject:@"NO" forKey:@"checked"];
        [cell setChecked:NO];
        NSString *StrID = [[SiteListArray objectAtIndex:index] objectForJSONKey:@"id"];
        [SiteIdArray removeObject:StrID];
    }
    DLog(@"SiteIdArrar 是%@",SiteIdArray);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


//滑动删除
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSString *Strid = [[SiteListArray objectAtIndex:index] objectForJSONKey:@"id"];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self DeleteSite:Strid];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
    }
}
-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


#pragma mark 添加小区
-(IBAction)AddSitr:(UIButton*)sender
{
    AddSiteAreaViewController *AddSieView = [[AddSiteAreaViewController alloc] init];
    [self pushNewViewController:AddSieView];
}


#pragma mark 网络请求获取数据
#pragma mark 网络请求获取数据
//获得小区配送列表
-(void)GetShopDeliverySiteList
{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *SilteListUrl = [NSString stringWithFormat:@"%@%@",BASEURL,ShopDeliverySiteList];
    NSString *strUrl = [[RestHttpRequest SharHttpRequest] AppendPublickKey:SilteListUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         
         if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"])
         {
             //配置数据源
             SiteListArray = [Dic objectForKey:@"CallInfo"];
             
             DLog(@"SiteListArray 是%@",SiteListArray);
             
             
             for (int i = 0;i<SiteListArray.count;i++)
             {
                 if ([[[SiteListArray objectAtIndex:i]objectForJSONKey:@"isused"]isEqualToString:@"1"])
                 {
                     NSString *Strid = [[SiteListArray objectAtIndex:i] objectForJSONKey:@"id"];
                     if (![SiteIdArray containsObject:Strid])
                     {
                         [SiteIdArray addObject:Strid];//选中的ID
                     }
                 }
             }
             DLog(@"选中的小区的ID是%@",SiteIdArray);
             [SiteTable reloadData];
             //根据SiteListArray为Contacts 添加数据,添加NO 或YES设置选中或未选中
             for (int i = 0; i <SiteListArray.count; i++)
             {
                 NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                 [dic setValue:@"NO" forKey:@"checked"];
                 [Contacts addObject:dic];
             }
         }
         else
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"请重新获取小区数据!"];
         }
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
}


-(void)DeleteSite:(NSString*)SiteId
{
    NSString *StrUlr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",BASEURL,ShopDeliverySite,[[Utility Share] storeId],@"?siteId=",SiteId,@"&uid=",[[Utility Share] userId]];
    NSString *UrlStr = [[RestHttpRequest SharHttpRequest]ApendPubkey:StrUlr InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger DELETE:UrlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"])
         {
         [self GetShopDeliverySiteList];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[Tools_HUD shareTools_MBHUD] alertTitle:@"网络请求错误,请重新请求!"];
     }];
}

- (IBAction)Refresh:(UIButton*)sender
{
    NSString *SiteList = [SiteIdArray componentsJoinedByString:@","];
    [self RefrshShopSiteStatus:SiteList];
}


#pragma mark 小区管理
-(void)RefrshShopSiteStatus:(NSString*)siteid
{
    
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *payLoadStr =  [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@",@"siteList=",siteid]];
    NSString *StrUlr = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopDeliverySiteList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *strUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:StrUlr InputResourceId:[[Utility Share] storeId] InputPayLoad:payLoadStr ];
    
    NSURL *url = [NSURL URLWithString:strUrl];
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
             
             [self GetShopDeliverySiteList];
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"更新成功!"];
         }
         else
         {
             [[ Tools_HUD shareTools_MBHUD] alertTitle:@"更新失败!"];
         }
         
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    [op start];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

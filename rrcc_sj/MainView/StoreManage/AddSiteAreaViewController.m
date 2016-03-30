//
//  AddSiteAreaViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
// 添加配送小区

#import "AddSiteAreaViewController.h"
#import "AddSiteTableViewCell.h"

@interface AddSiteAreaViewController ()<UISearchBarDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *SiteTable;
    __weak IBOutlet UISearchBar *MySearchBar;
                NSMutableArray  *SiteListArray;
    __weak IBOutlet UILabel *NotiCeLb;//提示LB
}
@property (strong,nonatomic)  NSString *strid;

@end

@implementation AddSiteAreaViewController
@synthesize strid;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"添加配送小区";
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [SiteTable setTableFooterView:view];
     SiteTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = RGB(245, 245, 245);
    SiteTable.backgroundColor = RGB(245, 245, 245);
    [MySearchBar setBackgroundImage:[UIImage imageNamed:@"SearchBar"]];
    
//    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
//    [self.view addGestureRecognizer:scrolTap];
      // Do any additional setup after loading the view from its nib.
}



#pragma mark UISearchBar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search];
    [MySearchBar resignFirstResponder];
    [MySearchBar setShowsCancelButton:NO animated:NO];
}

//搜索
-(void)search
{
    
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",BASEURL,ShopSiteList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId],@"&key=",MySearchBar.text];
    NSString *strUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:@"" ];
    NSString *UrlStr = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[AppDelegate Share].manger GET:UrlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
             if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"])
             {
                SiteListArray = [Dic objectForKey:@"CallInfo"];
                 if (SiteListArray.count == 0)
                 {
                     [[Tools_HUD shareTools_MBHUD] alertTitle:@"没有相关小区,请重新搜索"];
                 }
                [SiteTable reloadData];
             }
             else
             {
                 [[Tools_HUD shareTools_MBHUD] alertTitle:[Dic objectForJSONKey:@"ErrorMsg"]];
             }
             
             [[Tools_HUD shareTools_MBHUD] hideBusying];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
            [[Tools_HUD shareTools_MBHUD] hideBusying];
         }];
}
    


#pragma mark UITableView Delegate && Datasource

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return SiteListArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSDictionary *dic = [SiteListArray objectAtIndex:index];
    NSString    *Identifier = dic.description.md5;
    AddSiteTableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (Cell == nil)
    {
        Cell = [[[NSBundle mainBundle] loadNibNamed:@"AddSiteTableViewCell" owner:self options:nil] lastObject];
        Cell.CellBackView.backgroundColor =RGB(245, 245, 245);
        Cell.SiteNameLb.text = [[SiteListArray objectAtIndex:index] objectForJSONKey:@"name"];
        Cell.SiteAdressLb.text = [[SiteListArray objectAtIndex:index] objectForJSONKey:@"address"];
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(10,80, kScreenWidth-20,10)];
        cellView.backgroundColor = [UIColor clearColor];
        [Cell addSubview:cellView];
    }
    [Cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return Cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    strid= [[SiteListArray objectAtIndex:index] objectForJSONKey:@"id"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否添加此小区" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
    
    [self.view addSubview:alert];
    [alert show];
    
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1)
    {
        [self AddSite:strid];
    }
    else
    {
        return;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark 添加配送小区列表

-(void)AddSite:(NSString*)siteId
{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopDeliverySite,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *payLoadStr = [[Utility Share] base64Encode: [NSString stringWithFormat:@"%@%@",@"siteId=",siteId]];
    
    NSString *StrUr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:payLoadStr ];
    NSURL *url = [NSURL URLWithString:StrUr];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:payLoadStr];
    //发送网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                        cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"])
         {
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"添加成功"];
         }
         else
         {
             [[ Tools_HUD shareTools_MBHUD] alertTitle:@"添加失败"];
         }
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    [op start];
}



#pragma mark 关闭键盘


-(void)closeKeyBoard
{
    
    [MySearchBar resignFirstResponder];
    
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

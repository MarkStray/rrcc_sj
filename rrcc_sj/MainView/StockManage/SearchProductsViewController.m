//
//  SearchProductsViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-6-9.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "SearchProductsViewController.h"
#import "AdeDetailProductsViewController.h"

@interface SearchProductsViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
                        NSArray *PredicateArray;//搜索返回的数据
                    UIImageView *ItemImg;//物品图像
                    UILabel     *ItemNameLb;//物品名字
                    UILabel     *ShouJiaLb;//售价名
                    UILabel     *ShouJiaPriceLb;//售价
                    UILabel     *SalePriceLb;//促销价
                    UILabel     *PriceLb;//价格
                    UILabel     *AdvicePriceLb;//建议价
                    UIButton    *ShevlButt;//上架下架按钮
    __weak IBOutlet UISearchBar *MySearchBar;
    __weak IBOutlet UILabel     *NoticeLb;//提示
    __weak IBOutlet UITableView *MyTableView;
}
@property (strong,nonatomic)   NSMutableArray *SearchArray;

@end

@implementation SearchProductsViewController
@synthesize ProductsArray,SearchArray;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"库存管理";
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [MyTableView setTableFooterView:view];
    NoticeLb.backgroundColor = RGB(191, 228, 195);
    NoticeLb.textColor = RGB(0, 205, 65);
    [MySearchBar setBackgroundImage:[UIImage imageNamed:@"SearchBar"]];
    SearchArray = [NSMutableArray array];
    SearchArray = ProductsArray ;
}


#pragma mark - TableView Delegate&&DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return SearchArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    NSDictionary *Celldic = [SearchArray objectAtIndex:index];
    NSString *Identifier = Celldic.description.md5;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSString *urlStr = [[[SearchArray objectAtIndex:index] objectForJSONKey:@"imgurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *logoUrl = [NSURL URLWithString:urlStr];
        
        ItemImg = [[UIImageView alloc] initWithFrame:CGRectMake(34,5, 70, 70)];
        [ItemImg sd_setImageWithURL:logoUrl placeholderImage:[UIImage imageNamed:@"default_veg"]];

        NSString *str =[NSString stringWithFormat:@"%@%@",[[SearchArray objectAtIndex:index] objectForJSONKey:@"skuname"],[[SearchArray objectAtIndex:index] objectForJSONKey:@"spec"]];
        ItemNameLb = [RHMethods labelWithFrame:CGRectMake(XW(ItemImg)+5,0,200, 25) font:Font(15.0f) color:[UIColor blackColor] text:str];
        NSString *PriceStr = [[SearchArray objectAtIndex:index] objectForJSONKey:@"price"];
        ShouJiaLb = [RHMethods labelWithFrame:CGRectMake(X(ItemNameLb), YH(ItemNameLb),30,25) font:Font(13.0f) color:[UIColor darkGrayColor] text:[NSString stringWithFormat:@"%@%@",@"售价:",PriceStr]];
        ShouJiaPriceLb = [RHMethods labelWithFrame:CGRectMake(XW(ShouJiaLb),YH(ItemNameLb),150, 25) font:Font(13.0f) color:[UIColor redColor] text:PriceStr];
        NSString *SaleStr = [NSString stringWithFormat:@"%@%@",@"建议价:",[[SearchArray objectAtIndex:index] objectForJSONKey:@"avgprice"]];
        AdvicePriceLb = [RHMethods labelWithFrame:CGRectMake(X(ItemNameLb),YH(ShouJiaLb),80, 25) font:Font(13.0f) color:[UIColor lightGrayColor] text:SaleStr];
        
        NSString *SalePriceStr = [NSString stringWithFormat:@"%@",[[SearchArray objectAtIndex:index] objectForJSONKey:@"saleprice"]];
        NSString *OnSale  = [NSString stringWithFormat:@"%@",[[SearchArray objectAtIndex:index] objectForJSONKey:@"onsale"]];
        if (![SalePriceStr isEqualToString:@"(null)"] && ![SalePriceStr isEqualToString:@"0.00"]&& [OnSale isEqualToString:@"1"]){
            SalePriceLb = [RHMethods labelWithFrame:CGRectMake(XW(AdvicePriceLb), Y(AdvicePriceLb), 80, 25) font:Font(13.0f) color:[UIColor redColor] text:[NSString stringWithFormat:@"%@%@",@"促销价:",SalePriceStr]];
            [cell addSubview:SalePriceLb];
        }
        //获的上架或下架的字段 设Tag 值为indexpath.row,方便取商品的Id
        ShevlButt = [RHMethods buttonWithFrame:CGRectMake(kScreenWidth-53,17.5,45,45) title:nil image:@"" bgimage:@""];
        ShevlButt.tag = [[[SearchArray objectAtIndex:index] objectForJSONKey:@"skuid"] integerValue];
        NSString *strDel = [[SearchArray objectAtIndex:index] objectForJSONKey:@"isdel"];
        if ([strDel isEqualToString:@"1"]){ //1 下架，0上架
            [ShevlButt setBackgroundImage:[UIImage imageNamed:@"UnShevl"] forState:UIControlStateNormal];
            [ShevlButt addTarget:self action:@selector(UnShevl:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [ShevlButt setBackgroundImage:[UIImage imageNamed:@"Shevl"] forState:UIControlStateNormal];
            [ShevlButt addTarget:self action:@selector(Shevl:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:ItemImg];
        [cell addSubview:ItemNameLb];
        [cell addSubview:ShouJiaLb];
        [cell addSubview:ShouJiaPriceLb];
        [cell addSubview:AdvicePriceLb];
        [cell addSubview:ShevlButt];
    }
    return cell;
}



-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    NSDictionary *OrderDic = [SearchArray objectAtIndex:index];
    AdeDetailProductsViewController *DetailProductView = [[AdeDetailProductsViewController alloc] init];
    DetailProductView.ItemsDic = OrderDic;
    DetailProductView.TypeString = @"0";//0为修改商品 1为增加商品
    [self pushNewViewController:DetailProductView];
    [self closeKeyBoard];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

//更新请求
#pragma mark 上架或下架
-(void)Shevl:(UIButton*)sender{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSInteger tag = [sender tag];
    NSString *StrID =[NSString stringWithFormat:@"%ld",(long)tag];
    NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,RefreshProducList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *payload = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=unsale",@"&skuList=",StrID]];
    
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:payload];
    NSURL *url = [NSURL URLWithString:urlStr];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:payload];
    //发送网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                        cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
         if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"]){
             //更新成功
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"更新成功!"];
             [self.navigationController popViewControllerAnimated:YES];
         }else{
             [[Tools_HUD shareTools_MBHUD] alertTitle:[responseObject objectForJSONKey:@"ErrorMsg"]];
        }
        [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    [op start];
}

-(void)UnShevl:(UIButton*)sender{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSInteger tag = [sender tag];
    NSString *StrID =[NSString stringWithFormat:@"%ld",(long)tag];
    NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,RefreshProducList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *payload = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=sale",@"&skuList=",StrID]];
    
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:payload];
    NSURL *url = [NSURL URLWithString:urlStr];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:payload];
    //发送网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                        cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"]){
            //刷新表
            [[Tools_HUD shareTools_MBHUD] alertTitle:@"更新成功!"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [[ Tools_HUD shareTools_MBHUD] alertTitle:[responseObject objectForJSONKey:@"ErrorMsg"]];
         }
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    [op start];
 }


#pragma mark UISearceBar
-(void)searchRequest:(NSString*)searchText{
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"skuname",searchText];
    SearchArray = [[ProductsArray filteredArrayUsingPredicate:predicateString] mutableCopy] ;
    if ([searchText isEqualToString:@""]){
        SearchArray = ProductsArray;
    }
    NoticeLb.text = [NSString stringWithFormat:@"%@%@%@%lu%@",@"搜索",searchText,@"共有",(unsigned long)SearchArray.count,@"款产品"];
    [MySearchBar resignFirstResponder];
    [MySearchBar setShowsCancelButton:NO animated:NO];
    [MyTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchRequest:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchBar:searchBar textDidChange:searchBar.text];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:NO];
}

#pragma mark 关闭键盘
-(void)closeKeyBoard{
    [MySearchBar resignFirstResponder];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end

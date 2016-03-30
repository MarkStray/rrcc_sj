//
//  AddProductsViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "AddProductsViewController.h"
#import "AdeDetailProductsViewController.h"

@interface AddProductsViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    
    NSArray        *PredicateArray;//搜索返回的数据
    NSMutableArray *_SearchArray;
    NSMutableArray *ProductsArray;
    UIButton       *ShevlButt;//上架下架按钮
    UIImageView    *ItemImg;//物品图像
    UILabel        *ItemNameLb;//物品名字
    UILabel        *ShouJiaLb;//售价名
    UILabel        *ShouJiaPriceLb;//售价
    UILabel        *PriceLb;//价格
    UILabel        *AdvicePriceLb;//建议价
    __weak IBOutlet   UISearchBar  *BaseSearchBar;
    __weak IBOutlet   UITableView  *AddTable;
    __weak IBOutlet   UILabel      *NoticeLb;//提示的搜索信息UILabel
    
}

@end

@implementation AddProductsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"增加商品";
    UIView *view         = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [AddTable setTableFooterView:view];
    NoticeLb.backgroundColor = RGB(191, 228, 195);
    NoticeLb.textColor       = RGB(0, 205, 65);
    [BaseSearchBar setBackgroundImage:[UIImage imageNamed:@"SearchBar"]];
    [self Search];
    _SearchArray = [NSMutableArray  array];
    _SearchArray = ProductsArray;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ClenMemory) userInfo:nil repeats:YES];
    
}

#pragma mark 搜索
-(void)searchRequest:(NSString*)searchText{
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"skuname",searchText];
    _SearchArray = [[ProductsArray filteredArrayUsingPredicate:predicateString] mutableCopy] ;
    if ([searchText isEqualToString:@""]){
        _SearchArray = ProductsArray;
    }
    NoticeLb.text = [NSString stringWithFormat:@"%@%@%@%lu%@",@"搜索",searchText,@"共有",(unsigned long)_SearchArray.count,@"款产品"];
    [BaseSearchBar resignFirstResponder];
    [BaseSearchBar setShowsCancelButton:NO animated:NO];
    [AddTable reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchRequest:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchBar:searchBar textDidChange:searchBar.text];
    [BaseSearchBar resignFirstResponder];
    [BaseSearchBar setShowsCancelButton:NO animated:NO];
}

#pragma mark - TableView Delegate&&DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _SearchArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    NSDictionary *Celldic = [_SearchArray objectAtIndex:index];
    NSString *Identifier = Celldic.description.md5;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil){
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSString *urlStr =[[[_SearchArray objectAtIndex:index] objectForJSONKey:@"imgurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *logoUrl = [NSURL URLWithString:urlStr];
        
        ItemImg  = [[UIImageView alloc] initWithFrame:CGRectMake(30,5, 70, 70)];
        [ItemImg sd_setImageWithURL:logoUrl placeholderImage:[UIImage imageNamed:@"default_veg"]];
        NSString *str =[NSString stringWithFormat:@"%@%@",[[_SearchArray objectAtIndex:index] objectForJSONKey:@"skuname"],[[_SearchArray objectAtIndex:index] objectForJSONKey:@"spec"]];
        ItemNameLb = [RHMethods labelWithFrame:CGRectMake(XW(ItemImg)+5,0,200, 25) font:Font(15.0f) color:[UIColor blackColor] text:str];
        NSString *PriceStr = [[_SearchArray objectAtIndex:index] objectForJSONKey:@"price"];
        ShouJiaLb = [RHMethods labelWithFrame:CGRectMake(X(ItemNameLb), YH(ItemNameLb),30,25) font:Font(13.0f) color:[UIColor darkGrayColor] text:[NSString stringWithFormat:@"%@%@",@"售价:",PriceStr]];
        ShouJiaPriceLb = [RHMethods labelWithFrame:CGRectMake(XW(ShouJiaLb),YH(ItemNameLb),150, 25) font:Font(13.0f) color:[UIColor redColor] text:PriceStr];
        NSString *SaleStr = [NSString stringWithFormat:@"%@%@",@"建议价:",[[_SearchArray objectAtIndex:index] objectForJSONKey:@"avgprice"]];
        AdvicePriceLb = [RHMethods labelWithFrame:CGRectMake(X(ItemNameLb),YH(ShouJiaLb),150, 25) font:Font(13.0f) color:[UIColor lightGrayColor] text:SaleStr];

        [cell addSubview:ItemImg];
        [cell addSubview:ItemNameLb];
        [cell addSubview:ShouJiaLb];
        [cell addSubview:ShouJiaPriceLb];
        [cell addSubview:AdvicePriceLb];
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [BaseSearchBar resignFirstResponder];
    NSInteger index = indexPath.row;
    NSDictionary *dic = [_SearchArray objectAtIndex:index];
    AdeDetailProductsViewController *AddDetailView = [[AdeDetailProductsViewController alloc] init];
    AddDetailView.ItemsDic = dic;
    AddDetailView.TypeString = @"1";//1表示增加商品
    [self pushNewViewController:AddDetailView];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark 搜索数据
-(void)Search{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *ProuductUrl = [NSString stringWithFormat:@"%@%@",BASEURL,ShopProductList];
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] BackSearchUrl:ProuductUrl InputResourceId:[[Utility Share] storeId] InputKey:@"all"];
    [[AppDelegate Share].manger GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        ProductsArray = Dic[@"CallInfo"];
        _SearchArray = ProductsArray;
        [AddTable reloadData];
        [[Tools_HUD shareTools_MBHUD] hideBusying];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         [[Tools_HUD shareTools_MBHUD] alertTitle:@"网络加载失败,请重新获取!"];
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
}


#pragma mark 关闭键盘 
-(void)closeKeyBoard{
    [BaseSearchBar resignFirstResponder];
}

-(void)ClenMemory
{
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
      // Dispose of any resources that can be recreated.
}

@end

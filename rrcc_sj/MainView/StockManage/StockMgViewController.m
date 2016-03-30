//
//  StockMgViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-6-1.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "StockMgViewController.h"
#import "CustomTableViewCell.h"
#import "AddProductsViewController.h"
#import "selectTypeRightView.h"
#import "SearchProductsViewController.h"
#import "AdeDetailProductsViewController.h"
BOOL MangeBool = YES;

@interface StockMgViewController ()<selectTypeRightViewViewDelegate,UITableViewDelegate,UITableViewDataSource>{
                     float       StkTable_f;
                 NSInteger        indexSelectType;//选择索引
                NSInteger        selectIndex;//选择索引
             NSMutableArray      *ProductListArray;
             NSMutableArray      *selectArray;//分类数组
    //以下为Brand 数据源，用来获得数据和分离数据
                    NSArray      *ResultArray;
             NSMutableArray      *BrandNameArray;//商品名称数组
             NSMutableArray      *BrangIdArray;//BrandID
             NSMutableArray      *NameArray;//分离后的名称
             NSMutableArray      *IdArray;//分离后的BrandId;
        NSMutableDictionary      *ClassDic;//分类Dic
                 //定义控件
                 UIImageView     *ItemImg;//物品图像
                     UILabel     *ItemNameLb;//物品名字
                     UILabel     *ShouJiaLb;//售价名
                     UILabel     *ShouJiaPriceLb;//售价
                     UILabel     *PriceLb;//价格
                     UILabel     *AdvicePriceLb;//建议价
                     UILabel     *SalePriceLb;// 促销价
                    UIButton     *ShevlButt;//上架下架按钮
       selectTypeRightView       *selectView;//选择控件
    __weak IBOutlet UIView       *OperationView; //操作界面
    __weak IBOutlet UIButton     *AllButt;//全部商品按钮
    __weak IBOutlet UIButton     *ManageButt;//批量管理按钮
    __weak IBOutlet UITableView  *StKTable;

}
@end

@implementation StockMgViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //网络请求获得商品数据,且用户刷新数据
    [self GetShopProducetList];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //去除多余的分割线
    UIView *view         = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [StKTable setTableFooterView:view];
    self.title = @"库存管理";
    //添加导航栏按钮按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(AddProduct:)];
    //初始化数据
    ProductListArray  =[NSMutableArray array];
    BrandNameArray    =[[NSMutableArray alloc] initWithCapacity:0];
    BrangIdArray      =[[NSMutableArray alloc] initWithCapacity:0];
    ResultArray       =[[NSArray alloc] init];
    //隐藏操作界面
    OperationView.hidden = YES;
    //UITableView 支持多选
    StKTable.allowsMultipleSelectionDuringEditing = YES;
    StkTable_f = StKTable.frame.size.height;
}
//隐藏分类View
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (selectView.showHidden){
        [selectView hidden];
    }
}
#pragma mark  按钮方法
//添加商品方法4//批量管理按钮
-(IBAction)MangeButt:(id)sender{
    //BOOL 值判断按钮点击状态
    if (MangeBool){
        StKTable.frame = CGRectMake(X(StKTable), Y(StKTable),XW(StKTable),YH(StKTable)-88);
        [StKTable setEditing:YES animated:YES];
        [ManageButt setTitle:@"取消管理" forState:UIControlStateNormal];
        [ManageButt setTitleColor:RGBCOLOR(7, 136,16) forState:UIControlStateNormal];
        OperationView.hidden = NO;
        MangeBool = NO;
    }else{
        StKTable.frame = CGRectMake(X(StKTable), Y(StKTable),XW(StKTable),YH(StKTable));
        [ManageButt setTitle:@"批量管理" forState:UIControlStateNormal];
        [StKTable setEditing:NO animated:YES];
        //否则的话隐藏operationview
        [ManageButt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        OperationView.hidden = YES;
        MangeBool = YES;
    }
}


#pragma mark UITableView Delegate && Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ProductListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    NSDictionary *Celldic = [ProductListArray objectAtIndex:index];
    NSString *Identifier = Celldic.description.md5;
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        NSString *urlStr = [[[ProductListArray objectAtIndex:index] objectForJSONKey:@"imgurl"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *logoUrl = [NSURL URLWithString:urlStr];
        ItemImg = [[UIImageView alloc] initWithFrame:CGRectMake(34,5, 70, 70)];
        [ItemImg sd_setImageWithURL:logoUrl placeholderImage:[UIImage imageNamed:@"default_veg"]];
        NSString *str =[NSString stringWithFormat:@"%@%@",[[ProductListArray objectAtIndex:index] objectForJSONKey:@"skuname"],[[ProductListArray objectAtIndex:index] objectForJSONKey:@"spec"]];
        ItemNameLb = [RHMethods labelWithFrame:CGRectMake(XW(ItemImg)+5,0,160, 25) font:Font(15.0f) color:[UIColor blackColor] text:str];
        NSString *PriceStr = [NSString stringWithFormat:@"%@%@",@"￥",[[ProductListArray objectAtIndex:index] objectForJSONKey:@"price"]];
        ShouJiaLb = [RHMethods labelWithFrame:CGRectMake(X(ItemNameLb), YH(ItemNameLb),30,25) font:Font(13.0f) color:[UIColor darkGrayColor] text:[NSString stringWithFormat:@"%@",@"售价:"]];
        
        ShouJiaPriceLb = [RHMethods labelWithFrame:CGRectMake(XW(ShouJiaLb),YH(ItemNameLb),50, 25) font:Font(13.0f) color:[UIColor redColor] text:PriceStr];

        NSString *SaleStr = [NSString stringWithFormat:@"%@%@",@"建议价:",[[ProductListArray objectAtIndex:index] objectForJSONKey:@"avgprice"]];
        AdvicePriceLb = [RHMethods labelWithFrame:CGRectMake(X(ItemNameLb),YH(ShouJiaLb),70, 25) font:Font(13.0f) color:[UIColor lightGrayColor] text:SaleStr];
        
        NSString *SalePriceStr = [NSString stringWithFormat:@"%@",[[ProductListArray objectAtIndex:index] objectForJSONKey:@"saleprice"]];
        NSString *OnSale      =  [NSString stringWithFormat:@"%@",[[ProductListArray objectAtIndex:index] objectForJSONKey:@"onsale"]];
        
        if (![SalePriceStr isEqualToString:@"(null)"] && ![SalePriceStr isEqualToString:@"0.00"]&& [OnSale isEqualToString:@"1"]){
            SalePriceLb = [RHMethods labelWithFrame:CGRectMake(XW(ShouJiaPriceLb), Y(AdvicePriceLb), 80, 25) font:Font(13.0f) color:[UIColor redColor] text:[NSString stringWithFormat:@"%@%@",@"促销价:",SalePriceStr]];
            [cell addSubview:SalePriceLb];
        }
      
        ShevlButt = [RHMethods buttonWithFrame:CGRectMake(kScreenWidth-53,17.5,45,45) title:nil image:@"" bgimage:@""];
        //设Tag 值为indexpath.row,方便取商品的Id
        ShevlButt.tag = indexPath.row;
        //获的上架或下架的字段
        NSString *strDel = [[ProductListArray objectAtIndex:index] objectForJSONKey:@"isdel"];
        //下架 1下架，0上架
        if ([strDel isEqualToString:@"1"]){
            [ShevlButt setBackgroundImage:[UIImage imageNamed:@"UnShevl"] forState:UIControlStateNormal];
            [ShevlButt addTarget:self action:@selector(UnShevl:) forControlEvents:UIControlEventTouchUpInside];
        }else{   //上架
            [ShevlButt setBackgroundImage:[UIImage imageNamed:@"Shevl"] forState:UIControlStateNormal];
            [ShevlButt addTarget:self action:@selector(Shevl:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:ShevlButt];
        [cell addSubview:ItemImg];
        [cell addSubview:ItemNameLb];
        [cell addSubview:ShouJiaLb];
        [cell addSubview:ShouJiaPriceLb];
        [cell addSubview:AdvicePriceLb];
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    if (![tableView isEditing]){
        NSDictionary *OrderDic = [ProductListArray objectAtIndex:index];
        NSString     *SalerStr = [OrderDic objectForJSONKey:@"onsale"];
        AdeDetailProductsViewController *DetailProductView = [[AdeDetailProductsViewController alloc] init];
        DetailProductView.ItemsDic = OrderDic;
        DetailProductView.TypeString = @"0";//0为修改商品 1为增加商品
        //是否开启促销
        if ([SalerStr isEqualToString:@"1"]){
            DetailProductView.OnSalerStr = @"1";
        }else{
            DetailProductView.OnSalerStr = @"0";
        }
        [self pushNewViewController:DetailProductView];
    }
  }

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark 获得商品列表
-(void)GetShopProducetList{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    
    NSString *ProuductUrl = [NSString stringWithFormat:@"%@%@",BASEURL,ShopProductList];
    NSString *StrUrl = [[RestHttpRequest SharHttpRequest] AppendPublickKey:ProuductUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:StrUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        ProductListArray = Dic[@"CallInfo"];
        [StKTable reloadData];
        //分类菜单配置数据源
        [AllButt setTitle:@"商品分类" forState:UIControlStateNormal];
        //分离数据
        for (int i=0;i<ProductListArray.count;i++){
            NSString *brandNameStr = [[ProductListArray objectAtIndex:i] objectForJSONKey:@"brandname"];
            [BrandNameArray addObject:brandNameStr];
            NSString *brandIdStr   = [[ProductListArray objectAtIndex:i] objectForJSONKey:@"brandid"];
            [BrangIdArray addObject:brandIdStr];
         }
        NameArray = [NSMutableArray array];
        IdArray   = [NSMutableArray array];
        //去除重复的数据
        for (unsigned i = 0;i<BrandNameArray.count;i++){
            if ([NameArray containsObject:[BrandNameArray objectAtIndex:i]]== NO){
                [NameArray addObject:[BrandNameArray objectAtIndex:i]];
            }
        }
        //去除重复的数据
        for (unsigned i=0;i<BrangIdArray.count;i++){
            if ([IdArray containsObject:[BrangIdArray objectAtIndex:i]] == NO){
                [IdArray addObject:[BrangIdArray objectAtIndex:i]];
            }
        }
        ClassDic  = [[NSMutableDictionary alloc] init];
        for (int i = 0;i<IdArray.count;i++){
            selectIndex = [[IdArray objectAtIndex:i] integerValue];
            NSString *selectStr = [NSString stringWithFormat:@"%ld",(long)selectIndex];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"brandid like %@",selectStr];
            ResultArray = [ProductListArray filteredArrayUsingPredicate:predicate];
            [ClassDic setObject:ResultArray forKey:[IdArray objectAtIndex:i]];
        }
        //添加全部商品字段
        if (ProductListArray.count != 0){
            [ClassDic  setObject:ProductListArray forKey:@"0"];
        }
        [NameArray addObject:@"全部"];
        [IdArray   addObject:@"0"];
        
        [[Tools_HUD shareTools_MBHUD] hideBusying];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        [[Tools_HUD shareTools_MBHUD] hideBusying];

     }];
}

#pragma mark 一键更新
-(IBAction)RefreshProducts:(id)sender{
    //获得所选的indexPaths并遍历所选的index ,转为数组，并序列化为字符串
    NSArray *selectedRows = [StKTable indexPathsForSelectedRows];
    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    for (NSIndexPath *selectionIndex in selectedRows){
        [indicesOfItemsToDelete addIndex:selectionIndex.row];
    }
    NSMutableArray *IndexArray = [NSMutableArray array];
    NSMutableArray *skuArray = [NSMutableArray array];
    [indicesOfItemsToDelete enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        NSString *String = [NSString stringWithFormat:@"%lu",(unsigned long)idx];
        [IndexArray addObject:String];
    }];
    //遍历所选的
    for (int i= 0;i<IndexArray.count;i++){
        NSString *StrId = [[ProductListArray objectAtIndex:i]objectForJSONKey:@"skuid"];
        [skuArray addObject:StrId];
    }
    NSString *SkuList = [skuArray componentsJoinedByString:@","];
    [self RefreshShevlStatus:SkuList ShevlType:@"2"];
}

-(void)RefreshStatus:(NSString*)skulist{
    
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,RefreshProducList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    NSString *payload = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=1",@"&skuList=",skulist]];
    
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:payload ];
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
            //刷新
            [self GetShopProducetList];
        }else{
            [[Tools_HUD shareTools_MBHUD] alertTitle:[responseObject objectForJSONKey:@"ErrorMsg"]];
        }
        [[Tools_HUD shareTools_MBHUD] hideBusying];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
     }];
    [op start];
}

#pragma mark 多选上架或下架
-(IBAction)Shevle:(UIButton*)sender{
    //获取按钮的Tag 值
    NSInteger tag = [sender tag];
    //获得所选的indexPaths并遍历所选的index ,转为数组，并序列化为字符串
    NSArray *selectedRows = [StKTable indexPathsForSelectedRows];
    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    for (NSIndexPath *selectionIndex in selectedRows){
        [indicesOfItemsToDelete addIndex:selectionIndex.row];
    }
    NSMutableArray *IndexArray = [NSMutableArray array];
    NSMutableArray *skuArray = [NSMutableArray array];
    [indicesOfItemsToDelete enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        NSString *String = [NSString stringWithFormat:@"%lu",(unsigned long)idx];
        [IndexArray addObject:String];
    }];
    //遍历所选的 根据所取的index 获得SkuiD
    for (int i= 0;i<IndexArray.count;i++){
        NSInteger Index = [[IndexArray objectAtIndex:i] integerValue];
        NSString *SkuId = [[ProductListArray objectAtIndex:Index] objectForJSONKey:@"skuid"];
        [skuArray addObject:SkuId];
    }
    NSString *SkuList = [skuArray componentsJoinedByString:@","];
    switch (tag){
        case 105:
            [self RefreshShevlStatus:SkuList ShevlType:@"0"];//0位上架，1为下架
            break;
        case 106:
            [self RefreshShevlStatus:SkuList ShevlType:@"1"];
            break;
        default:
            break;
    }
}

-(void)RefreshShevlStatus:(NSString*)shevl ShevlType:(NSString*)shevlType{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSString *payload;
    NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,RefreshProducList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    if ([shevlType isEqualToString:@"1"]){
        payload  = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=unsale",@"&skuList=",shevl]];
    }
    if ([shevlType isEqualToString:@"0"]){
        payload  = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=sale",@"&skuList=",shevl]];
    }
    if ([shevlType isEqualToString:@"2"]){
        payload  = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=update",@"&skuList=",shevl]];
    }
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:payload ];
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
            [self GetShopProducetList];
        }else{
            [[ Tools_HUD shareTools_MBHUD] alertTitle:@"更新失败"];
         }
        [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         
     }];
    [op start];
}

//更新请求
#pragma mark 上架或下架
-(void)Shevl:(UIButton*)sender{
    [[Tools_HUD shareTools_MBHUD] showBusying];
    NSInteger tag = [sender tag];
    NSString *StrID =[[ProductListArray objectAtIndex:tag] objectForJSONKey:@"skuid"];
    NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,RefreshProducList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *payload  = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=unsale",@"&skuList=",StrID]];
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:payload ];
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
            [self GetShopProducetList];
        }else{
            [[ Tools_HUD shareTools_MBHUD] alertTitle:[responseObject objectForJSONKey:@"ErrorMsg"]];
        }
        [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
    
         [[Tools_HUD shareTools_MBHUD] hideBusying];
     }];
    [op start];
}

//下架
-(void)UnShevl:(UIButton*)sender{
    NSInteger tag = [sender tag];
    NSString *StrID =[[ProductListArray objectAtIndex:tag] objectForJSONKey:@"skuid"];
    NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,RefreshProducList,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *payload  = [[Utility Share] base64Encode:[NSString stringWithFormat:@"%@%@%@",@"action=sale",@"&skuList=",StrID]];
    NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[[Utility Share] storeId] InputPayLoad:payload ];
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
            [self GetShopProducetList];
        }else{
            [[ Tools_HUD shareTools_MBHUD] alertTitle:[responseObject objectForJSONKey:@"ErrorMsg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DLog(@"Error: %@", [error localizedDescription]);
    }];
    [op start];
}

#pragma mark SelectTypeView Delegate
-(IBAction)selectType:(id)sender{
    if (!selectView){
        selectView = [[selectTypeRightView alloc] initWithFrame:CGRectMake(0,108,kScreenWidth, kScreenHeight-108)];
        selectView.delegateType = self;
    }
    if (selectView.showHidden){
        [selectView hidden];
    }else{
        selectView.DataDic   = ClassDic;
        selectView.DataArray = NameArray;
        selectView.IdArray   = IdArray;
        selectView.strType   = @"stock_type";
        selectView.indexS    = indexSelectType;
        [selectView show];
    }
}

-(void)selectTypeRightViewCell:(selectTypeRightView *)sv object:(NSInteger)index ItemNamr:(NSString *)name{
    NSString *ReplaceName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    indexSelectType = index;
    NSString *strType = [NSString stringWithFormat:@"%ld",(long)indexSelectType];
    ProductListArray = nil;
    [StKTable reloadData];
    ProductListArray = [ClassDic objectForKey:strType];
    NSString *count = [NSString stringWithFormat:@"%@%@%lu%@",ReplaceName,@"(",(unsigned long)ProductListArray.count,@")"];
    [AllButt setTitle:count forState:UIControlStateNormal];
    [StKTable reloadData];
}


#pragma mark Push到搜索界面
-(IBAction)PushSearchView:(id)sender{
    if (selectView.showHidden){
        [selectView hidden];
    }
    SearchProductsViewController *SearchView = [[SearchProductsViewController alloc] init];
    SearchView.ProductsArray = ProductListArray;
    [self pushNewViewController:SearchView];
}

#pragma mark Push 到添加商品界面
-(void)AddProduct:(id)sender{
    AddProductsViewController *AddPuctsView = [[AddProductsViewController alloc] init];
    [self pushNewViewController:AddPuctsView];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


@end

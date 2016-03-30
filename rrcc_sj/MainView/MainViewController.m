    

//
//  MainViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-20.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "MainViewController.h"
#import "MyBillViewController.h"
#import "OrderTableViewCell.h"
#import "OrderDetailViewController.h"
#import "OrderManageViewController.h"
#import "ActPromViewController.h"
#import "StoreViewController.h"
#import "StockMgViewController.h"
#import "LoginViewController.h"
#import "Orders.h"
#import "CoreDateManager.h"
#import "OrderRequestCenter.h"

//static int Page   = 20;//一次取20条数据
//static int OffSet = 1; //从第一页开始取 
//
@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSDictionary       *storDic;//商铺信息
    NSMutableArray     *orderListArray;
    NSArray            *fliterArray;

    NSMutableDictionary*OrderListDic;//获取订单列表
    NSMutableArray     *ReadArray;//从数据库读取的数据
    NSMutableArray     *SectionTitleArray;//SectionHeader
    CoreDateManager    *OrderDataManage;
    OrderRequestCenter *orderRequest;//订单网络请求模块
}

@property (weak, nonatomic) IBOutlet UITableView *OrderTable;

@end

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"首页";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"账单" style:UIBarButtonItemStyleDone target:self action:@selector(PushToMyBillView)];
    _OrderTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self RefreshOrdersInfo];
    SectionTitleArray = [[NSMutableArray alloc] init];
    OrderListDic  = [[NSMutableDictionary alloc] init];
    //初始化后台
    BgTask = [[BackgroundTask alloc] init];
    [BgTask startBackgroundTasks:60 target:self selector:@selector(BackgroundCallBack)];
    //初始化CoreData和订单请求
    OrderDataManage = [[CoreDateManager alloc] init];
    orderRequest    = [[OrderRequestCenter alloc] init];


     //注册通知，监听推送
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    //接受数据刷新的通知
    [defaultCenter addObserver:self
                    selector:@selector(RefreshData:)
                         name:@"RefreshData"
                       object:nil];
    //网络请求错误
    [defaultCenter addObserver:self
                      selector:@selector(NetWorkError:)
                         name:@"NetWorkError"
                        object:nil];
}


#pragma mark UItableView Delegate && DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return SectionTitleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    NSString *key = [SectionTitleArray objectAtIndex:section];
    NSArray  *keyArray = [OrderListDic objectForJSONKey:key];
    return keyArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"Identifier";
    NSInteger index   = indexPath.row;
    OrderTableViewCell *OrderCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!OrderCell){
        OrderCell = [[[NSBundle mainBundle] loadNibNamed:@"OrderTableViewCell" owner:self options:nil] lastObject];
        OrderCell.backgroundColor = RGBCOLOR(244, 244, 244);
    }
    NSString *key = [SectionTitleArray objectAtIndex:indexPath.section];
    NSArray  *Array = [OrderListDic objectForJSONKey:key];
    
    OrderCell.OrderCodeLb.text = [[Array objectAtIndex:index] objectForJSONKey:@"ordercode"];
    NSInteger payment  = [[[Array objectAtIndex:index] objectForJSONKey:@"payment"] integerValue];
    NSInteger has_paid = [[[Array objectAtIndex:index] objectForJSONKey:@"has_paid"] integerValue];
    NSInteger status   = [[[Array objectAtIndex:index] objectForJSONKey:@"status"] integerValue];
    //订单状态
    switch (payment){
        case 1:
            OrderCell.PayStatusImg.image = [UIImage imageNamed:@"CashPay"];
            break;
        case 2:
            OrderCell.PayStatusImg.image = [UIImage imageNamed:@"OnLinePay"];
            break;
        default:
            break;
    }
   
    if (status == 1 && has_paid == 0){
        OrderCell.OrderStatusLb.text  = @"未接单-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 1 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"未接单-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 2 && has_paid == 0){
        OrderCell.OrderStatusLb.text = @"已确认-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 2 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"已确认-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 3 && has_paid == 0){
        OrderCell.OrderStatusLb.text = @"已完成-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderRedStatus.png"];
    }
    if (status == 3 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"已完成-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderRedStatus.png"];
    }
    if (status == 4 && has_paid == 0){
        OrderCell.OrderStatusLb.text = @"商户取消-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 4 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"商户取消-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 5 && has_paid == 0){
        OrderCell.OrderStatusLb.text = @"用户取消-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 5 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"用户取消-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 6 && has_paid == 0){
        OrderCell.OrderStatusLb.text = @"过期订单-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 6 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"过期订单-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderGrayStatus.png"];
    }
    if (status == 7 && has_paid == 0){
        OrderCell.OrderStatusLb.text = @"已评价-未支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderRedStatus.png"];
    }
    if (status == 7 && has_paid == 1){
        OrderCell.OrderStatusLb.text = @"已评价-已支付";
        OrderCell.StatusImg.image = [UIImage imageNamed:@"OrderRedStatus.png"];
    }
    OrderCell.SvAddressLb.text = [[Array objectAtIndex:index] objectForJSONKey:@"address"];
    OrderCell.SvTimeLb.text    = [[Array objectAtIndex:index] objectForJSONKey:@"svtime"];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(10,95, kScreenWidth-20,10)];
    cellView.backgroundColor = [UIColor clearColor];
    [OrderCell addSubview:cellView];
    OrderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return OrderCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index   = indexPath.row;
    NSInteger section = indexPath.section;
    NSString *Key = [SectionTitleArray objectAtIndex:section];
    NSDictionary *dic = [[OrderListDic objectForJSONKey:Key]objectAtIndex:index];
    OrderDetailViewController *OrderDetailView = [[OrderDetailViewController alloc] init];
    OrderDetailView.OrderId     = [dic objectForJSONKey:@"orderId"];
    OrderDetailView.OrderTel    = [dic objectForJSONKey:@"tel"];
    OrderDetailView.OrderCode   = [dic objectForJSONKey:@"ordercode"];
    OrderDetailView.OrderAdress = [dic objectForJSONKey:@"address"];
    OrderDetailView.OrderRemark = [dic objectForJSONKey:@"remark"];
    [self pushNewViewController:OrderDetailView];
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *rigntHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,5,self.OrderTable.frame.size.width, 20)];
    rigntHeaderView.backgroundColor = RGBA(2, 207, 65, 1);
    
    UILabel *headerLb = [RHMethods labelWithFrame:CGRectMake(5,0,kScreenWidth, 20) font:Font(15.0f) color:[UIColor blackColor] text:  [NSString stringWithFormat:@"%@%@",[SectionTitleArray objectAtIndex:section],@"预约订单"]];
    
    [rigntHeaderView addSubview:headerLb];
    return rigntHeaderView;

}


#pragma Button Action
-(void)PushToMyBillView{
    MyBillViewController *MyBillView = [[MyBillViewController alloc] init];
    [self pushNewViewController:MyBillView];
}

-(IBAction)SelectManagerView:(id)sender{
    NSInteger tag = [sender tag];
    StockMgViewController *stockManGeView =[[StockMgViewController alloc] init];
    ActPromViewController *actPromView    =[[ActPromViewController alloc] init];
    OrderManageViewController *orderView  =[[OrderManageViewController alloc] init];
    StoreViewController *StorView = [[StoreViewController alloc] init];
    switch (tag){
        case 101:
            [self pushNewViewController:orderView];
            break;
        case 102:
            [self pushNewViewController:stockManGeView];
            break;
        case 103:
            [self pushNewViewController:actPromView];
            break;
        case 104:
            [self pushNewViewController:StorView];
            break;
        default:
            break;
    }
}

#pragma mark 下拉刷新,获取数据,上拉加载更多
-(void)RefreshOrdersInfo{
    __weak __typeof(self) weakSelf = self;
    self.OrderTable.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf GetOrderList];
    }];
    [self.OrderTable.header beginRefreshing];
}

//获取订单列表
-(void)GetOrderList{
    //第一次登陆,如果没有店铺信息则获取店铺信息，再获取订单列表
    if (![[Utility Share] storeDic]){
        [orderRequest GetStoreInfo];
    }else{
        [orderRequest GetOrderList:@"0" Status:@"1"];//根据状态获取订单列表
    }
}


//读取数据库,刷新数据
-(void)RefreshData:(NSNotification*)notification{
    [self.OrderTable.header endRefreshing];
    //配置TableView 的数据源
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status =1"];
    [self DataSourceHandle:[OrderDataManage FliterFromDb:predicate]];
}

//网络请求错误
-(void)NetWorkError:(NSNotification*)notification{
    [self.OrderTable.header endRefreshing];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"status =1"];
    [self DataSourceHandle:[OrderDataManage FliterFromDb:predicate]];
}
//后台回调
-(void)BackgroundCallBack{
    [orderRequest GetOrderList:@"-10" Status:@"1"];
}

//分栏数据处理
-(void)DataSourceHandle:(NSArray*)listArray{
    
    NSMutableArray *InsertTimeArray = [[NSMutableArray alloc] init];
    NSMutableArray *orderArray  = [[NSMutableArray alloc] init];
    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
    
    for (NSObject *obj in listArray){
        NSString *timeStr  = [[obj valueForKey:@"svtime"] substringToIndex:10];
        [InsertTimeArray addObject:timeStr];
    }
    
    for (int i = 0;i<InsertTimeArray.count;i++){
        if ([sectionArray containsObject:[InsertTimeArray objectAtIndex:i]] == NO){
            [sectionArray addObject:[InsertTimeArray objectAtIndex:i]];
        }
    }
    
    for (Orders *info  in listArray){
        NSMutableDictionary *InfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:info.ordercode,@"ordercode",info.address,@"address",info.delivery,@"delivery",info.status,@"status",info.payment,@"payment",info.has_paid,@"has_paid",info.orderId,@"orderId",info.svtime,@"svtime",[info.svtime substringToIndex:10],@"identifier",info.tel,@"tel",info.remark,@"remark",nil];
        [orderArray addObject:InfoDic];
    }
    
    for (NSObject *object in sectionArray){
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"identifier =%@",object];
        fliterArray = [orderArray filteredArrayUsingPredicate:predicate];
        if (fliterArray.count >0){
            [OrderListDic setObject:fliterArray forKey:[object copy]];
        }
    }
    SectionTitleArray = [sectionArray copy];
    [self.OrderTable reloadData];    
}



#pragma mark 极光推送，获得RegistrationID 上传服务器
- (void)networkDidSetup:(NSNotification *)notification{
}

- (void)networkDidClose:(NSNotification *)notification{
}

- (void)networkDidRegister:(NSNotification *)notification{
    [[notification userInfo] valueForKey:@"RegistrationID"];
}

- (void)networkDidLogin:(NSNotification *)notification{
    if ([APService registrationID]){
        NSString *RegisterId = [APService registrationID];
        [self PostPushRegisID:RegisterId];
    }
}


- (void)unObserveAllNotifications{
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidSetupNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidCloseNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidRegisterNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidLoginNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidReceiveMessageNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFServiceErrorNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:@"RefreshData"
                            object:nil];
    [defaultCenter removeObserver:self
                             name:@"NetWorkError"
                           object:nil];
}

-(void)PostPushRegisID:(NSString*)RegisID{
    
    NSString *payLoadStr = [NSString stringWithFormat:@"%@%@",@"pushId=",RegisID];
    NSString *PushUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,CustomerPushId,[[Utility Share] userId],@"?uid=",[[Utility Share] userId]];
    
    NSString *UrlPush = [[RestHttpRequest SharHttpRequest] ApendPubkey:PushUrl InputResourceId:[[Utility Share] userId] InputPayLoad:[[Utility Share] base64Encode:payLoadStr]];
    NSURL *url = [NSURL URLWithString:UrlPush];
    //获得HTTP Body
    NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:[[Utility Share] base64Encode:payLoadStr]];
    //发送网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:10];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"]){
            }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         NSLog(@"Error: %@", [error localizedDescription]);
     }];
    [op start];
}

//注销通知
-(void)dealloc{
    [self unObserveAllNotifications];
}
@end

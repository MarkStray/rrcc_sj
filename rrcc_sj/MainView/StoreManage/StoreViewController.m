//
//  StoreViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "StoreViewController.h"
#import "DistributeRuleViewController.h"
#import "OperatTimeViewController.h"
#import "ChangeUserInfoViewController.h"
#import "ChangeAdressViewController.h"
#import "BindZhiFuBaoViewController.h"
#import "ChangPwdViewController.h"
#import "DetailWXViewController.h"
#import "SiteMangeViewController.h"

#import "BLEViewController.h"
#import "BltPrintFormat.h"
#import "OrderRequestCenter.h"
#import "CoreDateManager.h"
#import "LoginViewController.h"


@interface StoreViewController ()
{
    NSMutableArray *ImgsArray;
    NSMutableArray *NamesArray;
    NSMutableDictionary *StoresDic;
    NSMutableDictionary *MyDic;
    NSMutableDictionary *InfoDic;
    NSMutableArray   *InfoArray;
    NSString         *IsOpenStr;
    OrderRequestCenter *orderRequest;//订单请求

}
@property (weak, nonatomic)   IBOutlet   UITableView *StoreMaagetable;
@property (strong,nonatomic)  UISwitch   *SwitchView;
@end

@implementation StoreViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [[Utility Share] readUserInfoFromDefault];
    InfoDic = [[Utility Share]storeDic];
    [_StoreMaagetable reloadData];
}



- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"店铺管理";
    ImgsArray  = [[NSMutableArray alloc] initWithObjects:@"Image1",@"Image2",@"Image3",@"Image5",@"Image6",@"Image7",@"Image8",@"Image9",@"Blt",@"syn",@"key",nil];
    NamesArray = [[NSMutableArray alloc] initWithObjects:@"配送范围",@"配送规则",@"营业时间",@"店铺地址",@"支付宝绑定",@"修改密码",@"开通微店",@"营业状态",@"连接蓝牙",@"手动同步订单",@"账号注销",nil];
    UIView *view =[[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_StoreMaagetable setTableFooterView:view];
    
    orderRequest    = [[OrderRequestCenter alloc] init];
    //注册通知
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(synchronizeDate:)
                          name:@"synchronize"
                        object:nil];

}

#pragma mark UITableView Delegate && DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return NamesArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    static NSString *Identifier = @"Identifier";
    UITableViewCell *StoreCell  = [tableView dequeueReusableCellWithIdentifier:Identifier];
    //在复用里，初始化 控件，再在外面赋值
    if (StoreCell == nil){
        StoreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
        StoreCell.textLabel.font = Font(15.0f);
        StoreCell.detailTextLabel.font = Font(13.0f);
        StoreCell.textLabel.textColor = [UIColor darkGrayColor];
        StoreCell.detailTextLabel.textColor = [UIColor darkGrayColor];
        StoreCell.textLabel.text = [NamesArray objectAtIndex:index];
        //创建UISwiTchView
        if (index == 7){
            _SwitchView = [[UISwitch alloc]initWithFrame:CGRectMake(kScreenWidth-70, 10, 100, 30)];
            [_SwitchView addTarget:self action:@selector(ChangeSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [StoreCell addSubview:_SwitchView];
        }
    }
    //配置Icon 和标题
    StoreCell.imageView.image = [UIImage imageNamed:[ImgsArray objectAtIndex:indexPath.row]];
    if (index == 0){
        NSString *StrSiteListr = [InfoDic objectForJSONKey:@"sitelist"];
        if (StrSiteListr.length >0){
            StoreCell.detailTextLabel.text = [InfoDic objectForJSONKey:@"sitelist"];
            StoreCell.detailTextLabel.text =[InfoDic objectForKey:@"sitelist"];
        }else{
            StoreCell.detailTextLabel.text = @"";
        }
    }
    //逻辑错误
    if (index == 1){
        NSString *Rule1      = [NSString stringWithFormat:@"%@%@",[InfoDic objectForJSONKey:@"minorder"],@"元起送,"];
        NSString *Rule2      = [NSString stringWithFormat:@"%@%@%@",@"配送费:",[InfoDic objectForJSONKey:@"deliverycost"],@"元"];
        NSString *Rule3      = [NSString stringWithFormat:@"%@%@%@",@"满",[InfoDic objectForJSONKey:@"freedelivery"],@"免费配送"];
        NSString *Rule4      = [NSString stringWithFormat:@"%@%@%@",Rule1,Rule2,Rule3];
        StoreCell.detailTextLabel.text = Rule4;
    }
    if (index == 2){
        NSString *Salestime = [NSString stringWithFormat:@"%@%@%@",[InfoDic objectForJSONKey:@"starttime"],@"-",[InfoDic objectForJSONKey:@"closetime"]];
        StoreCell.detailTextLabel.text = Salestime;
    }
    if (index == 3){
        StoreCell.detailTextLabel.text = [InfoDic objectForJSONKey:@"address"];
    }
    if (index == 4){
        StoreCell.detailTextLabel.text = [[Utility Share] aiLiPayCountStr];
    }
    if (index == 7){
        NSString *isopen = [[Utility Share] openStatus];
        if ([isopen isEqualToString:@"1"]){
            _SwitchView.on = YES;
            IsOpenStr = @"1";
            StoreCell.detailTextLabel.text = @"营业中";
        }else if ([isopen isEqualToString:@"0"]){
            _SwitchView.on = NO;
            IsOpenStr  = @"0";
            StoreCell.detailTextLabel.text = @"打烊中";
        }
    }

    if (index == 8) {
        if ([[BltPrintFormat ShareBLTPrint].ConnectState  isEqualToString:@"1"]){
            StoreCell.detailTextLabel.text = @"蓝牙打印机已连接";
        }else{
             StoreCell.detailTextLabel.text = @"蓝牙打印机未连接";
        }
    }
    if (index == 9){
        StoreCell.detailTextLabel.text = @"手动同步最近三天订单";
    }
    StoreCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (index == 7){
        StoreCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (index == 9){
        StoreCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (index == 10){
        StoreCell.accessoryType = UITableViewCellAccessoryNone;
    }
    StoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return StoreCell;
}

/*
 //营业时间
 NSString *Salestime = [NSString stringWithFormat:@"%@%@%@",[InfoDic objectForJSONKey:@"starttime"],@"-",[InfoDic objectForJSONKey:@"closetime"]];
 //联系电话
 NSString *Contacts   = [NSString stringWithFormat:@"%@%@%@",[InfoDic objectForJSONKey:@"contact"],@":",[InfoDic objectForJSONKey:@"tel"]];
 
 
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    DistributeRuleViewController *RuleView       =[[DistributeRuleViewController alloc]init];
    OperatTimeViewController     *OperTimeView   =[[OperatTimeViewController     alloc]init];
    BindZhiFuBaoViewController   *BindZhifuView  =[[BindZhiFuBaoViewController   alloc]init];
    ChangeAdressViewController   *ChangAdressView=[[ChangeAdressViewController   alloc]init];
    ChangPwdViewController       *ChangePwdView  =[[ChangPwdViewController       alloc]init];
    DetailWXViewController       *DetailWxView   =[[DetailWXViewController       alloc]init];
    SiteMangeViewController      *SiteMangeView  =[[SiteMangeViewController      alloc]init];
    BLEViewController            *BleView        = [[BLEViewController           alloc]init];
     switch (index){
        case 0:
            [self pushNewViewController:SiteMangeView];
            break;
        case 1:
            [self pushNewViewController: RuleView];
            break;
        case 2:
            [self pushNewViewController:OperTimeView];
            break;
        case 3:
            [self pushNewViewController:ChangAdressView];
            break;
        case 4:
            [self pushNewViewController:BindZhifuView];
            break;
        case 5:
            [self pushNewViewController:ChangePwdView];
            break;
        case 6:
            [self pushNewViewController:DetailWxView];
            break;
        case 8:
            [self pushNewViewController:BleView];
            break;
        case 9:
            [[Tools_HUD shareTools_MBHUD] showBusying];
            [orderRequest GetOrderList:@"-10" Status:@"2"];
            break;
        case 10:
            [self Logout];
            break;
        default:
            break;
    }
}


-(void)ChangeSwitch:(UISwitch*)sender
{
    
    NSString *payLoadStr;
    BOOL isButtonOn = [sender isOn];
    if (isButtonOn)
    {
        payLoadStr = [[Utility Share] base64Encode: [NSString stringWithFormat:@"%@%@",@"isopen=",@"1"]];
        [self RefreshStoreStatus:@"1" PayLoadStr:payLoadStr];
    }else{
         payLoadStr = [[Utility Share] base64Encode: [NSString stringWithFormat:@"%@%@",@"isopen=",@"0"]];
        [self RefreshStoreStatus:@"0" PayLoadStr:payLoadStr];
    }
}


-(void)RefreshStoreStatus:(NSString*)OpenType PayLoadStr:(NSString*)payLoadStr
{
    //开店
    if ([OpenType isEqualToString:@"1"])
    {
        NSString *OpeningUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopOpening,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
        NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:OpeningUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:payLoadStr ];
        NSURL *url = [NSURL URLWithString:urlStr];
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
                [[Utility Share] setOpenStatus:@"1"];
                 [[Utility Share] saveUserInfoToDefault];
                 [_StoreMaagetable reloadData];
             }else{
                 
                 [[Tools_HUD shareTools_MBHUD] alertTitle:@"更新失败"];
             }
             
      } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", [error localizedDescription]);
         }];
        [op start];
        
    }
    else if ([OpenType isEqualToString:@"0"])
    {
        
        NSString *OpeningUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopOpening,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
        
        NSString *urlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:OpeningUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:payLoadStr];
        NSURL *url = [NSURL URLWithString:urlStr];
        //获得HTTP Body
        NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:payLoadStr];
        //发送网络请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        [request setHTTPMethod:@"PUT"];
        [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
             if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"]){
                 [[Utility Share] setOpenStatus:@"0"];
                 [[Utility Share] saveUserInfoToDefault];
                 [_StoreMaagetable reloadData];
             }else{
                 [[Tools_HUD shareTools_MBHUD] alertTitle:@"更新失败"];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error){
             DLog(@"Error: %@", [error localizedDescription]);
         }];
        [op start];
    }
}


-(void)synchronizeDate:(NSNotification*)notification{
    [[Tools_HUD shareTools_MBHUD] alertTitle:@"订单同步成功!"];
    [[Tools_HUD shareTools_MBHUD] hideBusying];
}


-(void)Logout{
    
    UIAlertView *LogoAlert = [[UIAlertView alloc] initWithTitle:@"是否注销此账号,并重新登录!" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [LogoAlert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        //清空用户数据
        [[Utility Share] clearUserInfoInDefault];
        [[CoreDateManager Share] deleteData];//清空数据库
        //进入登录
        LoginViewController*LoginView = [[LoginViewController alloc] init];
        XHBaseNavigationController *LoginNav = [[XHBaseNavigationController alloc] initWithRootViewController:LoginView];
        LoginNav.navigationBar.translucent = NO;
        [AppDelegate Share].window.rootViewController = LoginNav;
    }
}

//移除通知
- (void)RemoveAllNotifications{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:@"synchronizeDate"
                           object:nil];
}

-(void)dealloc
{
    [self RemoveAllNotifications];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

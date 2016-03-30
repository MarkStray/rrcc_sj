//
//  RejectViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-6-1.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "RejectViewController.h"
#import "QRadioButton.h"

@interface RejectViewController ()<UITableViewDataSource,UITableViewDelegate,QRadioButtonDelegate,UITextViewDelegate,UIAlertViewDelegate>{
                 NSMutableArray *RejectArray;
                       NSString *SelectId;
                     UITextView *OtherTextView;//其它信息s
                IBOutlet UIView *HeaderView;
        __weak IBOutlet UILabel *OrderCodeLb;//订单号
        __weak IBOutlet UILabel *OrderTimeLb;//订单时间
    __weak IBOutlet UITableView *RejectTable;
}
@end

@implementation RejectViewController
@synthesize InfoDic;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"订单拒收";
    [RejectTable setTableHeaderView:HeaderView];
    OrderCodeLb.text = [NSString stringWithFormat:@"%@%@",@"订单编号:",[[InfoDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"ordercode"]];
    OrderTimeLb.text = [[InfoDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"svtime"];
    RejectArray = [NSMutableArray arrayWithObjects:@"配送信息有误",@"无法按时送达",@"库存不足",@"其他",nil];
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //注册监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return RejectArray.count+1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        if (index == 0){
            UILabel *RejectLb = [RHMethods labelWithFrame:CGRectMake(15, 5, 150,30) font:Font(17.0f) color:[UIColor darkGrayColor] text:@"拒绝原因"];
            [cell addSubview:RejectLb];
        }
        if (index == 1){
            QRadioButton *RejectButt = [[QRadioButton alloc] initWithDelegate:self groupId:@"1"];
            RejectButt.frame = CGRectMake(10,5,150,30);
            [RejectButt setTitle:@"配送信息有误" forState:UIControlStateNormal];
            [RejectButt setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [RejectButt.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
            [RejectButt addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
            RejectButt.tag = 1;
            [cell  addSubview:RejectButt];
       }
        if (index == 2){
            QRadioButton *ArriaveButton = [[QRadioButton alloc] initWithDelegate:self groupId:@"1"];
            ArriaveButton.frame = CGRectMake(10,5,150,30);
            [ArriaveButton setTitle:@"无法按时送达" forState:UIControlStateNormal];
            [ArriaveButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [ArriaveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
            [ArriaveButton addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
            ArriaveButton.tag = 2;
            [cell  addSubview:ArriaveButton];
        }
        if (index ==3){
            QRadioButton *StockButton = [[QRadioButton alloc] initWithDelegate:self groupId:@"1"];
            StockButton.frame = CGRectMake(10,5,150,30);
            [StockButton setTitle:@"库存不足" forState:UIControlStateNormal];
            [StockButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [StockButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
            [StockButton addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
            StockButton.tag = 3;
            [cell  addSubview:StockButton];
        }
        if (index == 4){
            QRadioButton *OtherButt = [[QRadioButton alloc] initWithDelegate:self groupId:@"1"];
            OtherButt.frame = CGRectMake(10,5,150,30);
            [OtherButt setTitle:@"其它" forState:UIControlStateNormal];
            [OtherButt setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [OtherButt.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
            [OtherButt addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
            OtherButt.tag = 4;
            OtherTextView  = [[UITextView alloc] initWithFrame:CGRectMake((kScreenWidth-(kScreenWidth-40))/2,YH(OtherButt),kScreenWidth-40,80)];
            OtherTextView.backgroundColor = RGB(245, 245, 245);
            OtherTextView.delegate = self;
            [cell addSubview:OtherTextView];
            [cell  addSubview:OtherButt];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)Click:(UIButton*)sender{
    NSInteger tag = [sender tag];
    SelectId = [NSString stringWithFormat:@"%ld",(long)tag];
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4){
        return 120;
    }
    return 40;
}

#pragma mark 订单操作
-(IBAction)Submit:(id)sender{
    NSInteger length = SelectId.length;
    if (length == 0){
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请选择拒绝原因!"];
    }else if ([SelectId isEqualToString:@"4"] && OtherTextView.text.length == 0){
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入拒绝原因!"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拒绝此订单" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        [self.view addSubview:alert];
        [alert show];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex  == 1)
    {
        NSString *PayLoadStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"action=",@"cancel",@"&cancelReasonId=",SelectId,@"&cancelReason=",OtherTextView.text,@"&shopId=",[[Utility Share] storeId]];
        NSString *PayLoad = [[Utility Share] base64Encode:PayLoadStr];
        NSString *OrderId = [[InfoDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"id"];
        NSString *BaseUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopOrder,OrderId,@"?uid=",[[Utility Share] userId]];
        NSString *UrlStr = [[RestHttpRequest SharHttpRequest] ApendPubkey:BaseUrl InputResourceId:OrderId InputPayLoad:PayLoad];
        NSString *UTF8URl = [UrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:UTF8URl];
        //获得HTTP Body
        NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:PayLoad];
        //发送网络请求
        [[Tools_HUD shareTools_MBHUD] showBusying];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                    cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        [request setHTTPMethod:@"put"];
        [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
            NSDictionary *ResponseDic = responseObject;
            if ([[ResponseDic objectForJSONKey:@"Success"] isEqualToString:@"1"]){
                [self.navigationController popViewControllerAnimated:YES];
                [[Tools_HUD shareTools_MBHUD] alertTitle:@"您已取消此订单"];
                [[Tools_HUD shareTools_MBHUD] hideBusying];
            }else{
                [[Tools_HUD shareTools_MBHUD] alertTitle:[ResponseDic objectForJSONKey:@"ErrorMsg"]];
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [[Tools_HUD shareTools_MBHUD] alertTitle:[error localizedDescription]];
        }];
        [op start];
    }
}

#pragma mark 键盘处理
-(void)handleKeyboardDidShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
//    CGFloat distanceToMove = kbSize.height;
//    NSLog(@"---->动态键盘高度:%f",distanceToMove);
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.3 animations:^{
        RejectTable.frame=CGRectMake(X(RejectTable),Y(RejectTable)-100, W(RejectTable),H(RejectTable));
    }];
}

//关闭键盘,界面回复原状
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.3 animations:^{
        RejectTable.frame=CGRectMake(X(RejectTable),Y(RejectTable)+100, W(RejectTable),H(RejectTable));
    }];
}

//关闭键盘
-(void)closeKeyBoard{
    [OtherTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  DetailWXViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-31.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "DetailWXViewController.h"

@interface DetailWXViewController ()<UITextViewDelegate>
{

    __weak IBOutlet UITextView *OrderTextView;//下单
    __weak IBOutlet UITextView *WatchText;//介绍
    __weak IBOutlet UITextView *SearchText;//查询
    
}

@end

@implementation DetailWXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"开通微店";
    [OrderTextView  setEditable:NO];
    [WatchText setEditable:NO];
    [SearchText setEditable:NO];
    OrderTextView.textColor = RGB(0,194, 61);
    WatchText.textColor     = RGB(0,194,61);
    SearchText.textColor    = RGB(0, 194, 61);
    [self GetWXUrl];
}

-(void)GetWXUrl
{
    NSString *WXUrl = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,CustomerRshop,[[Utility Share] storeId],@"?uid=",[[Utility Share] userId]];
    
    NSString *BaseUrl = [[RestHttpRequest SharHttpRequest] ApendPubkey:WXUrl InputResourceId:[[Utility Share] storeId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:BaseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        OrderTextView.text = dic[@"CallInfo"][0][@"order"];
        WatchText.text     = dic[@"CallInfo"][0][@"watch"];
        SearchText.text    = dic[@"CallInfo"][0][@"search"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

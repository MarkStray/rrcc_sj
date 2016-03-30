//
//  AddActViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-6-3.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "AddActViewController.h"
#import "IQActionSheetPickerView.h"


@interface AddActViewController ()<IQActionSheetPickerViewDelegate>
{
    __weak IBOutlet UIButton *StartButt;
    
    __weak IBOutlet UIButton *EndButt;
    
    
    __weak IBOutlet UITextField *PromCountsText;//优惠多少
    __weak IBOutlet UITextField *CountPriceText;//满多少
    __weak IBOutlet UITextField *PromPriceText;//优惠多少
}

@end

@implementation AddActViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"添加满减活动";
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [StartButt setTitle:currentTime forState:UIControlStateNormal];
    [EndButt   setTitle:currentTime forState:UIControlStateNormal];
    
    
    UIGestureRecognizer *scrolTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:scrolTap];
}


-(IBAction)SelectTime:(UIButton*)sender
{
    [self closeKeyBoard];
    NSInteger tag = sender.tag;
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"日期选择" delegate:self];
    if (tag == 1)
    {
        [picker setTag:1];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
    }
    if (tag == 2)
    {
        [picker setTag:2];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
    }
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (pickerView.tag == 1)
    {
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [StartButt setTitle:TimeStr forState:UIControlStateNormal];
    }
    if (pickerView.tag == 2)
    {
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [EndButt setTitle:TimeStr forState:UIControlStateNormal];
    }
    
}
#pragma mark 提交
-(IBAction)submit:(id)sender
{
   
    NSString *StartStr = StartButt.titleLabel.text;
    NSString *EndStr   = EndButt.titleLabel.text;
    
    NSInteger start = [[StartStr stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    NSInteger end   = [[EndStr stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
    
    
    //时间比较
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSInteger nowTime  = [currentTime integerValue];
    
    if (start < nowTime)
    {
         [[Tools_HUD shareTools_MBHUD] alertTitle:@"开始时间不能为过去的时间!"];
    }
    else if (end < start)
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"结束时间必须大于起始时间!"];
    }
    
    else if ([PromCountsText.text isEqual:@"" ])
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入优惠次数!"];
    }
    else if ([PromPriceText.text isEqual:@""])
    
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入优惠金额!"];
    }
    else if  ([CountPriceText.text isEqual:@""])
    {
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入满减金额!"];
    }
    else
    {

        NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@",BASEURL,ShopDiscount,@"?uid=",[[Utility Share] userId]];
        
        NSString *playod = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",@"shopId=",[[Utility Share] storeId],@"&limit=",CountPriceText.text,@"&discount=",PromPriceText.text,@"&num=",PromCountsText.text,@"&start=",StartButt.titleLabel.text,@"&expired=",EndButt.titleLabel.text];
        NSString *pladstr = [[Utility Share] base64Encode:playod];
        
        NSString *url = [[RestHttpRequest SharHttpRequest] ApendPubkey:strUrl InputResourceId:@"" InputPayLoad:pladstr];
        NSURL *BodyUrl = [NSURL URLWithString:url];
        //获得HTTP Body
        NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:pladstr];
        //发送网络请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:BodyUrl
                        cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        [request setHTTPMethod:@"post"];
        [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"])
             {
                 [[Tools_HUD shareTools_MBHUD] alertTitle:@"添加成功!"];
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 [[ Tools_HUD shareTools_MBHUD] alertTitle:@"添加失败,请重新添加"];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", [error localizedDescription]);
         }];
        [op start];

        
        
        
        
        
    }

    
    
    
    
    
    
    
    
    
    
}



#pragma mark 关闭键盘
- (void)closeKeyBoard
{
    [PromCountsText resignFirstResponder];
    [CountPriceText resignFirstResponder];
    [PromPriceText resignFirstResponder];
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

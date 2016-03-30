//
//  SelectTimeViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-22.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "SelectTimeViewController.h"
#import "DetailTimeBillViewController.h"
#import "IQActionSheetPickerView.h"

@interface SelectTimeViewController ()<IQActionSheetPickerViewDelegate>
{
    
    __weak IBOutlet UIButton *StartTimeButt;
    __weak IBOutlet UIButton *EndTimeButt;
    NSDictionary *DataDic;
}

@end

@implementation SelectTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的账单";
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [StartTimeButt setTitle:currentTime forState:UIControlStateNormal];
    [EndTimeButt   setTitle:currentTime forState:UIControlStateNormal];
}

-(IBAction)QueryDetail:(id)sender
{
    
    DataDic = [NSDictionary dictionary];
    DataDic = [NSDictionary dictionaryWithObjectsAndKeys:StartTimeButt.titleLabel.text,@"start",EndTimeButt.titleLabel.text,@"end",nil];
//    DLog(@"Data Dic 是%@",DataDic);
//    DLog(@"%@",[DataDic objectForJSONKey:@"start"]);
    
    
    DetailTimeBillViewController *DetailTimeView = [[DetailTimeBillViewController alloc] init];
    DetailTimeView.DetailDic = DataDic;
    [self pushNewViewController:DetailTimeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)dateTimePickerViewClicked:(UIButton *)sender
{
    
    NSInteger tag = sender.tag;
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Date Picker" delegate:self];
    if (tag == 101)
    {
        [picker setTag:101];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
    }
    if (tag == 102)
    {
        [picker setTag:102];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
    }
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (pickerView.tag == 101)
    {
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *TimeStr = [formatter stringFromDate:date];
    [StartTimeButt setTitle:TimeStr forState:UIControlStateNormal];
    }
    if (pickerView.tag == 102)
    {
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [EndTimeButt setTitle:TimeStr forState:UIControlStateNormal];
    }
    
  }
@end

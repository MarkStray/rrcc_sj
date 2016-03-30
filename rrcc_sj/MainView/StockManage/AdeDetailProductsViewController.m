//
//  AdeDetailProductsViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "AdeDetailProductsViewController.h"
#import "IQActionSheetPickerView.h"
#import "UniteSelectView.h"


@interface AdeDetailProductsViewController ()<IQActionSheetPickerViewDelegate,UITextViewDelegate,UniteSelctViewDelegate>
{
    __weak IBOutlet UIImageView *ProductImg;//产品图片
    __weak IBOutlet UILabel *ProductNameLb;//产品名称
    __weak IBOutlet UITextField *AvgWeightText;//重量
    __weak IBOutlet UITextField *NumText;//每份数量
    __weak IBOutlet UITextField *FeatureText;
    __weak IBOutlet UITextField *SalePriceText;//售价
    __weak IBOutlet UITextView *ProductDesTextView;//描述Text
    __weak IBOutlet UIScrollView *BackScrollView;
    __weak IBOutlet UIView *BackView;
    __weak IBOutlet UIButton *OpenButt;     //开启按钮
    IBOutlet  UIView *PromtionView; //促销界面
    __weak IBOutlet UITextField *PromPriceText;//促销价格
    __weak IBOutlet UITextField *PromNumtxt;   //促销数量
    __weak IBOutlet    UIButton *SubmitButt;   //提交按钮
    __weak IBOutlet    UIButton *StartTimeButt;//开始时间
    __weak IBOutlet    UIButton *EndTimeButt;  //结束时间
    __weak IBOutlet UIButton *UnitButt; //单位选择按钮
    NSString    *OnSale;   //是否为促销模式
    float     BG_f;     //BackScrollView的Frame
    UniteSelectView  *SelectView;//选择界面
    UITableView      *UniteTable;//选择TableView
    BOOL OpenBool;
 }

@end

@implementation AdeDetailProductsViewController

@synthesize ItemsDic,TypeString,OnSalerStr;

- (void)viewDidLoad{
    [super viewDidLoad];
    //根据类型判断，修改标题
    if ([TypeString isEqualToString:@"0"]){
        self.title = @"修改商品";
        [SubmitButt setTitle:@"确认修改" forState:UIControlStateNormal];
    }else{
        self.title = @"增加商品";
        [SubmitButt setTitle:@"增加商品" forState:UIControlStateNormal];
    }
    OpenBool = YES;
    OnSale = [ItemsDic objectForJSONKey:@"onsale"];//是否为促销中的商品
    //配置数据
    ProductNameLb.text       = [NSString stringWithFormat:@"%@", ItemsDic[@"skuname"]];
    AvgWeightText.text       = [NSString stringWithFormat:@"%@", ItemsDic[@"avgweight"]];
    
    if ([UnitButt.titleLabel.text isEqualToString:@"市斤"]){
        float salePrice = [[ItemsDic objectForJSONKey:@"price"] floatValue]/[AvgWeightText.text floatValue]*500;
        SalePriceText.text = [NSString stringWithFormat:@"%.2f",salePrice];
    }
    NumText.text  = [NSString stringWithFormat:@"%@", ItemsDic[@"avgnum"]];
    ProductDesTextView.text  = [NSString stringWithFormat:@"%@", ItemsDic[@"remark"]];
    //UIScrollView
    [BackScrollView setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    BackScrollView.scrollEnabled = YES;
    BackScrollView.userInteractionEnabled = YES;
    UIGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyBoard)];
    [BackScrollView addGestureRecognizer:tapScroll];
    ProductDesTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    
    //显示今日时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [StartTimeButt setTitle:currentTime forState:UIControlStateNormal];
    [EndTimeButt   setTitle:currentTime forState:UIControlStateNormal];
    
    PromNumtxt.text = [ItemsDic objectForJSONKey:@"saleamount"];
    //配置物品信息
    NSString *urlStr = [[ItemsDic objectForJSONKey:@"imgurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *logoUrl = [NSURL URLWithString:urlStr];
    [ProductImg sd_setImageWithURL:logoUrl];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //注册监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
//隐藏分类View
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (SelectView.showHidden){
        [SelectView hidden];
    }
}


-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:YES];
}

#pragma mark 开启和未开启
-(IBAction)OpenPromtion:(UIButton*)sender{
    if (OpenBool == YES)
    {
        [OpenButt setTitle:@"开启" forState:UIControlStateNormal];
        [OpenButt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        OpenBool = NO;
        
        [StartTimeButt setTitle:[ItemsDic objectForJSONKey:@"salestart"] forState:UIControlStateNormal];
        [EndTimeButt setTitle:[ItemsDic objectForJSONKey:@"saleexpired"] forState:UIControlStateNormal];
        
        PromPriceText.text = [ItemsDic objectForJSONKey:@"saleprice"];
        PromNumtxt.text    = [ItemsDic objectForJSONKey:@"saleamount"];
    
        //隐藏或显示促销界面
        //活动开启按钮的x坐标，和Y 坐标加上开启按钮的高度，自己查看分类，看封装的坐标函数
        // BackView.frame = CGRectMake(0, 0, kScreenWidth, YH(BackView)+220);
        CGPoint point = CGPointMake(OpenButt.frameX,OpenButt.frameY+OpenButt.frameSize.height);
        PromtionView.frameOrigin = point;
        [BackView addSubview:PromtionView];
        //操作界面高度为固定的220,调整CGPoint坐标
        SubmitButt.frameOrigin = CGPointMake(SubmitButt.frameX,YH(OpenButt)+220);
        [BackScrollView setContentSize:CGSizeMake(kScreenWidth,kScreenHeight+280)];
    }else if (OpenBool == NO){
        [OpenButt setTitle:@"暂不开启" forState:UIControlStateNormal];
        [OpenButt setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        OpenBool = YES;
        CGPoint  hiddenPoint     = CGPointMake(-1000, -1000);
        PromtionView.frameOrigin = hiddenPoint;
        SubmitButt.frameOrigin   = CGPointMake(SubmitButt.frameX, YH(OpenButt)+20);
        [BackScrollView setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    }
}
#pragma mark 时间
-(IBAction)DateTimePickerViceController:(UIButton*)sender{
    NSInteger tag = sender.tag;
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Date Picker" delegate:self];
    if (tag == 101){
        [self closeKeyBoard];
        [picker setTag:101];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
    }
    if (tag == 102){
        [self closeKeyBoard];
        [picker setTag:102];
        [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
        [picker show];
    }
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (pickerView.tag == 101){
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [StartTimeButt setTitle:TimeStr forState:UIControlStateNormal];
    }
    if (pickerView.tag == 102){
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *TimeStr = [formatter stringFromDate:date];
        [EndTimeButt setTitle:TimeStr forState:UIControlStateNormal];
    }
}

#pragma mark UniteSelectViewDelegate
-(void)selectUniteViewCell:(UniteSelectView *)sv object:(NSInteger)index{
    if (index == 0){
        [UnitButt setTitle:@"市斤" forState:UIControlStateNormal];
    }else{
        [UnitButt setTitle:@"份" forState:UIControlStateNormal];
    }
}

-(IBAction)UniteSelect:(id)sender{
    [self closeKeyBoard];
    if (!SelectView){
        SelectView = [[UniteSelectView alloc] initWithFrame:CGRectMake(0,0,kScreenWidth,kScreenHeight)];
        SelectView.delegateType = self;
        [BackView addSubview:SelectView];
    }
    if (SelectView.showHidden){
        [SelectView hidden];
    }else{
        NSArray *UniteArray = [NSArray arrayWithObjects:@"市斤",@"份",nil];
        SelectView.DataArray = UniteArray;
        [SelectView show];
    }
}

#pragma mark 网络请求,增加商品
-(IBAction)AddProduct:(id)sender{
    NSString *StartTimeStr;//开始时间
    NSString *EndTimeStr;//结束时间
    NSString *IfSale;//是否促销
    NSString *PromPriceStr;//促销价格
    NSString *NumStr;//促销数量
    NSString *SalePriceStr;//售价
    float    SalePrice;//售价
    if (FeatureText.text.length >10){
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"特征描述不能超过10个字!"];
        return;
    }
    if ([NumText.text length] == 0){
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请输入数量!"];
        return;
    }
    if ([AvgWeightText.text integerValue] < 0 || [NumText.text integerValue]<0 || [SalePriceText.text integerValue] <0  || [PromPriceText.text integerValue]<0 || [PromNumtxt.text integerValue]<0){
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"请重新输入"];
        return;
    }
    if (PromPriceText.text.length == 0 && [IfSale isEqualToString:@"1"]){
        [[Tools_HUD shareTools_MBHUD] alertTitle:@"促销价格不能为空!"];
        return;
    }
    
    if (OpenBool == NO)
    {
        NSString *StartStr = StartTimeButt.titleLabel.text;
        NSString *EndStr   = EndTimeButt.titleLabel.text;
        NSInteger start = [[StartStr stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        NSInteger end   = [[EndStr stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        if (end < start){
            [[Tools_HUD shareTools_MBHUD] alertTitle:@"开始时间必须小于结束时间"];
            return;
        }
    }
    
       if ([UnitButt.titleLabel.text isEqualToString:@"市斤"]){
       SalePrice = [SalePriceText.text floatValue]/500*[AvgWeightText.text floatValue];
       SalePriceStr = [NSString stringWithFormat:@"%.2f",SalePrice];
   }
   if ([UnitButt.titleLabel.text isEqualToString:@"份"]){
       SalePrice = [SalePriceText.text floatValue];
       SalePriceStr = [NSString stringWithFormat:@"%.2f",SalePrice];
   }
    NSString *IfSaleStr = [ItemsDic objectForJSONKey:@"onsale"];
    //是否开启促销配置参数
    if (OpenBool == YES && [IfSaleStr isEqualToString:@"1"]){
        StartTimeStr = [ItemsDic objectForJSONKey:@"salestart"];
        EndTimeStr   = [ItemsDic objectForJSONKey:@"saleexpired"];
        IfSale       = @"1";
        PromPriceStr = [ItemsDic objectForJSONKey:@"saleprice"];
        NumStr       = [ItemsDic objectForJSONKey:@"saleamount"];
    }
    else if (OpenBool == YES && [IfSaleStr isEqualToString:@"0"]){
        StartTimeStr = [ItemsDic objectForJSONKey:@"salestart"];
        EndTimeStr   = [ItemsDic objectForJSONKey:@"saleexpired"];
        IfSale       = @"0";
        PromPriceStr = [ItemsDic objectForJSONKey:@"saleprice"];
        NumStr       = [ItemsDic objectForJSONKey:@"saleamount"];
    }
    else
    {
        StartTimeStr = StartTimeButt.titleLabel.text;
        EndTimeStr   = EndTimeButt.titleLabel.text;
        PromPriceStr = PromPriceText.text;
        NumStr       = PromNumtxt.text;
        IfSale       = @"1";
    }
    //如果为0 为修改商品
    if ([TypeString isEqualToString:@"0"]){
        [[Tools_HUD shareTools_MBHUD] showBusying];
        NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@%@",BASEURL,ShopProduct,[ItemsDic objectForJSONKey:@"id"],@"?uid=",[[Utility Share] userId]];
        NSString *payloadStr = [NSString stringWithFormat:
                                @"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"feature=",FeatureText.text,@"&avgWeight=",AvgWeightText.text,@"&avgNum=",NumText.text,@"&price=",SalePriceStr,@"&remark=",ProductDesTextView.text,@"&onsale=",IfSale,@"&salePrice=",PromPriceStr,@"&saleAmount=",NumStr,@"&saleStart=",StartTimeStr,@"&saleExpired=",EndTimeStr];
        
        NSString *payload = [[Utility Share] base64Encode:[payloadStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSString *urlStr  = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:[ItemsDic objectForJSONKey:@"id"] InputPayLoad:payload];
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
                [[Tools_HUD shareTools_MBHUD] alertTitle:@"修改成功!"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [[ Tools_HUD shareTools_MBHUD] alertTitle:@"修改失败!"];
             }
             [[Tools_HUD shareTools_MBHUD] hideBusying];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error){
             
         }];
        [op start];
    }
        //如果为1 为增加商品
    if ([TypeString isEqualToString:@"1"]){
        [[Tools_HUD shareTools_MBHUD] showBusying];
        NSString *baseurl  = [NSString stringWithFormat:@"%@%@%@%@",BASEURL,ShopProduct,@"?uid=",[[Utility Share] userId]];
        NSString *payloadStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"shopId=",[[Utility Share]storeId],@"&skuId=",ItemsDic[@"skuid"],@"&feature=",FeatureText.text,@"&avgWeight=",AvgWeightText.text,@"&avgNum=",NumText.text,@"&price=",SalePriceStr,@"&remark=",ProductDesTextView.text,@"&onsale=",IfSale,@"&salePrice=",PromPriceStr,@"&saleAmount=",NumStr,@"&saleStart=",StartTimeStr,@"&saleExpired=",EndTimeStr];
        NSString *payload = [[Utility Share] base64Encode:[payloadStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSString *urlStr  = [[RestHttpRequest SharHttpRequest] ApendPubkey:baseurl InputResourceId:@"" InputPayLoad:payload];
        NSString *UTF8URl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:UTF8URl];
        //获得HTTP Body
        NSString *bodyStr = [[RestHttpRequest SharHttpRequest] GetHttpBody:payload];
        //发送网络请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                    cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        [request setHTTPMethod:@"post"];
        [request setHTTPBody: [bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
         if ([[responseObject objectForJSONKey:@"Success"] isEqualToString:@"1"]){
             //刷新表
             [[Tools_HUD shareTools_MBHUD] alertTitle:@"添加商品成功!"];
             [self.navigationController popViewControllerAnimated:YES];
         }else{
             [[ Tools_HUD shareTools_MBHUD] alertTitle:@"添加失败,请重新添加"];
         }
            [[Tools_HUD shareTools_MBHUD] hideBusying];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error){
         
     }];
        [op start];
    }
}

#pragma mark 键盘处理
-(void)handleKeyboardDidShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGFloat distanceToMove = kbSize.height;
    NSLog(@"---->动态键盘高度:%f",distanceToMove);
    
    if ([SalePriceText isEditing]){
        [UIView animateWithDuration:0.3 animations:^{
            BackScrollView.frame=CGRectMake(X(BackScrollView),Y(BackScrollView)-50, W(BackScrollView),H(BackScrollView));
        }];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.3 animations:^{
        BackScrollView.frame=CGRectMake(X(BackScrollView),Y(BackScrollView)-100, W(BackScrollView),H(BackScrollView));
    }];
}

//关闭键盘,界面回复原状
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.3 animations:^{
        BackScrollView.frame=CGRectMake(0,0,W(BackScrollView),H(BackScrollView));
    }];
}

#pragma mark 隐藏键盘
-(void)closeKeyBoard{
    [NumText resignFirstResponder];
    [FeatureText resignFirstResponder];
    [SalePriceText resignFirstResponder];
    [AvgWeightText resignFirstResponder];
    [ProductDesTextView resignFirstResponder];
    [PromPriceText resignFirstResponder];
    [PromNumtxt resignFirstResponder];
}

//移除通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

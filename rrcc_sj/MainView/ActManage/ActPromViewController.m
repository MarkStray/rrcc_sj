//
//  ActPromViewController.m
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "ActPromViewController.h"
#import "ActpromTableViewCell.h"
#import "ManJianViewController.h"
#import "ZenPinViewController.h"
#import "CuXiaoActViewController.h"
#import "StockMgViewController.h"

@interface ActPromViewController ()
@property (weak, nonatomic) IBOutlet UITableView *MainActTable;
@end

@implementation ActPromViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"活动促销";
    _MainActTable.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    static NSString *Identifier = @"Identifier";
    ActpromTableViewCell *ActCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (ActCell == nil){
        ActCell = [[[NSBundle mainBundle] loadNibNamed:@"ActpromTableViewCell" owner:self options:nil] lastObject];
        ActCell.CellbackView.backgroundColor = RGBCOLOR(242, 242, 242);
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(10,70, kScreenWidth-20,10)];
        cellView.backgroundColor = [UIColor clearColor];
        [ActCell addSubview:cellView];
        
        if (index == 0){
            ActCell.ActImage.image = [UIImage imageNamed:@"Jian"];
            ActCell.ActNameLb.textColor = RGB(69, 172, 222);
            ActCell.ActNameLb.text = @"满减活动";
            ActCell.ActDescLb.text = @"满减优惠,每单只限一次!";
            ActCell.ActDescLb.textColor = [UIColor darkGrayColor];
        }
        if (index == 1){
            ActCell.ActImage.image = [UIImage imageNamed:@"zen"];
            ActCell.ActNameLb.text = @"赠品活动";
            ActCell.ActDescLb.text = @"每单只限一次,可与满减累计!";
            ActCell.ActNameLb.textColor = RGB(255, 100, 65);
            ActCell.ActDescLb.textColor = [UIColor darkGrayColor];
        }
        if (index == 2){
            ActCell.ActImage.image = [UIImage imageNamed:@"cu"];
            ActCell.ActNameLb.text = @"促销活动";
            ActCell.ActDescLb.text = @"单品促销,可与满减赠品同时使用!";
            ActCell.ActNameLb.textColor = [UIColor redColor];
            ActCell.ActDescLb.textColor = [UIColor darkGrayColor];
        }
    }
    ActCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return ActCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = [indexPath row];
    ManJianViewController *manJianView =[[ManJianViewController alloc] init];
    ZenPinViewController  *zenPinView  =[[ZenPinViewController  alloc] init];
    StockMgViewController *StockMgView =[[StockMgViewController alloc] init];
    if (index == 0){
        [self pushNewViewController:manJianView];
    }
    if (index == 1){
        [self pushNewViewController:zenPinView];
    }
    if (index == 2){
        [self pushNewViewController:StockMgView];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

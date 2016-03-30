//
//  UniteSelectView.m
//  rrcc_sj
//
//  Created by lawwilte on 15-6-23.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "UniteSelectView.h"
#import "NSString+expanded.h"

@interface UniteSelectView()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableS;
}
@end

@implementation UniteSelectView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
    self.backgroundColor=RGBACOLOR(0, 0, 0, 0.4);
    UIControl *closeC=[[UIControl alloc]initWithFrame:self.bounds];
    [closeC addTarget:self action:@selector(hidden) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeC];
    
    tableS=[[UITableView alloc]initWithFrame:CGRectMake((kScreenWidth-300)/2,kScreenHeight/2,300,300)];
    tableS.dataSource = self;
    tableS.delegate=self;
    [tableS setBackgroundColor:[UIColor whiteColor]];
    UIView *view         = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableS setTableFooterView:view];
    [self addSubview:tableS];
    }
    return self;
}

#pragma mark tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[self.DataArray objectAtIndex:indexPath.row];
 
    NSString *identifier = dic.description.md5;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *NameStr = [NSString stringWithFormat:@"%@",[self.DataArray objectAtIndex:indexPath.row]];
    cell.textLabel.font = Font(15.0f);
    cell.textLabel.text =NameStr;
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.delegateType respondsToSelector:@selector(selectUniteViewCell:object:)])
    {
        [self.delegateType selectUniteViewCell:self object:indexPath.row];
    }
    [self hidden];
}



- (void)show
{
    self.showHidden=YES;
    float tempF=(self.DataArray.count) * 44;
    float tempY=tempF>(kApplicationFrameHeight-44)?(kApplicationFrameHeight-44):tempF;
    tableS.frame=CGRectMake(X(tableS), Y(tableS), W(tableS),0);
    [UIView animateWithDuration:tempY<300?0.4:0.6 animations:^{
        tableS.frame=CGRectMake(X(tableS), Y(tableS), W(tableS),tempY);
    }];
    [tableS reloadData];
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    
    self.hidden = NO;
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hidden
{
    self.showHidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

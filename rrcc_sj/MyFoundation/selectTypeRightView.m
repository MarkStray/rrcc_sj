//
//  selectTypeRightView.m
//  ZKwwlk
//
//  Created by junseek on 14-7-23.
//  Copyright (c) 2014年 五五来客. All rights reserved.
//

#import "selectTypeRightView.h"
#import "NSString+expanded.h"

@interface selectTypeRightView ()<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *tableS;
}
@end

@implementation selectTypeRightView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        // Initialization code
        self.frame=frame;
        self.backgroundColor=RGBACOLOR(0, 0, 0, 0.4);
        UIControl *closeC=[[UIControl alloc]initWithFrame:self.bounds];
        [closeC addTarget:self action:@selector(hidden) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeC];
        
        tableS=[[UITableView alloc]initWithFrame:CGRectMake(0,0,110,kScreenHeight)];
        tableS.dataSource = self;
        tableS.delegate=self;
        [tableS setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:tableS];
    }
    return self;
}


#pragma mark tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.DataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=[self.DataArray objectAtIndex:indexPath.row];
    BOOL abool=NO;
    if ( [[self.DataArray objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]){
        abool=YES;
    }
    NSString *identifier = dic.description.md5;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor=[UIColor clearColor];
        NSString *StrId = [_IdArray objectAtIndex:indexPath.row];
        NSArray *Array = [_DataDic objectForJSONKey:StrId];

        NSString *StrCount = [NSString stringWithFormat:@"%lu",(unsigned long)Array.count];
        NSString *NameStr = [NSString stringWithFormat:@"%@%@%@%@",[self.DataArray objectAtIndex:indexPath.row],@"(",StrCount,@")"];
        
        UILabel *lblName=[RHMethods labelWithFrame:CGRectMake(10, 12, 0, 20) font:Font(14) color:RGBCOLOR(0, 0, 0) text:abool?[dic valueForJSONStrKey:@"name"]:NameStr];
        
        [cell addSubview:lblName];
        [lblName setHighlightedTextColor:RGB(0, 185, 59)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger SelectIndex = [[_IdArray objectAtIndex:indexPath.row] integerValue];
    NSString *StrNamr     = [self.DataArray objectAtIndex:indexPath.row];
    if ([self.delegateType respondsToSelector:@selector(selectTypeRightViewCell:object:ItemNamr:)]){
        [self.delegateType selectTypeRightViewCell:self object:SelectIndex ItemNamr:StrNamr];
    }
    [self hidden];
}


- (void)show{
    self.showHidden=YES;
    float tempF=(self.DataArray.count) * 44;
    float tempY=tempF>(kApplicationFrameHeight-88)?(kApplicationFrameHeight-88):tempF;
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

- (void)hidden{
    self.showHidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end

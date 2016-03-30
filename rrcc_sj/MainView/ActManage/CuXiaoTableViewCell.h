//
//  CuXiaoTableViewCell.h
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CuXiaoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *SkuNameLb;//名字
@property (weak, nonatomic) IBOutlet UILabel *SalePriceLb;//售价
@property (weak, nonatomic) IBOutlet UILabel *NowPriceLb;//现价

@end

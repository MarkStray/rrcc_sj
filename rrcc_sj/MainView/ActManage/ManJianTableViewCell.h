//
//  ManJianTableViewCell.h
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManJianTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *CellbackView;
@property (weak, nonatomic) IBOutlet UILabel *ActDesLb;
@property (weak, nonatomic) IBOutlet UILabel *ActTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *TypeLb;
@property (weak, nonatomic) IBOutlet UILabel *NumberLb;//数量

@end

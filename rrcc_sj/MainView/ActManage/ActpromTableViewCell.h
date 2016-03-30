//
//  ActpromTableViewCell.h
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActpromTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *CellbackView;
@property (weak, nonatomic) IBOutlet UIImageView *ActImage;//活动Icon
@property (weak, nonatomic) IBOutlet UILabel *ActNameLb;//活动名
@property (weak, nonatomic) IBOutlet UILabel *ActDescLb;//活动描述



@end

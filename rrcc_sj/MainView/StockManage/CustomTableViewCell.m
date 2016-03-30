//
//  CustomTableViewCell.m
//  MuliteTable
//
//  Created by lawwilte on 15-5-30.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell
@synthesize m_checkImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self creat];
    }
    return self;
}
// 创建cell
- (void)creat
{
    if (m_checkImageView == nil)
    {
        m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UnSelectSite"]];
        m_checkImageView.frame = CGRectMake(kScreenWidth-60,13.5,18,18);
        [self addSubview:m_checkImageView];
    }
}


- (void)setChecked:(BOOL)checked
{
    if (checked)
    {
        m_checkImageView.frame = CGRectMake(kScreenWidth-60,13.5,18,18);
        m_checkImageView.image = [UIImage imageNamed:@"SelectSite"];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
    }
    else
    {
        m_checkImageView.frame = CGRectMake(kScreenWidth-60,13.5,18,18);
        m_checkImageView.image = [UIImage imageNamed:@"UnSelectSite"];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    m_checked = checked;
    }



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

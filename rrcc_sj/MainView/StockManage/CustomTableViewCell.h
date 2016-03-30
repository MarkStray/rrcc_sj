//
//  CustomTableViewCell.h
//  MuliteTable
//
//  Created by lawwilte on 15-5-30.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
{
BOOL			m_checked;
UIImageView*	m_checkImageView;
}

- (void)setChecked:(BOOL)checked;



@property (strong,nonatomic)UIImageView*	m_checkImageView;
@end

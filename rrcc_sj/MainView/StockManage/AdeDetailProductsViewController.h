//
//  AdeDetailProductsViewController.h
//  rrcc_sj
//
//  Created by lawwilte on 15-5-21.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdeDetailProductsViewController : XHBaseViewController

@property (strong,nonatomic) NSString      *TypeString;//类型，添加商品还是修改商品
@property (strong,nonatomic) NSString      *OnSalerStr;//是否开启了促销
@property (strong,nonatomic) NSDictionary  *ItemsDic;
@end

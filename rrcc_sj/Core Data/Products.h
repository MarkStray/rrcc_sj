//
//  Products.h
//  rrcc_sj
//
//  Created by lawwilte on 7/5/15.
//  Copyright (c) 2015 ting liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Products : NSObject
@property (nonatomic,strong) NSString *avgnum;
@property (nonatomic,strong) NSString *avgprice;
@property (nonatomic,strong) NSString *avgweight;
@property (nonatomic)int     brandid;
@property (nonatomic,strong) NSString *brandname;
@property (nonatomic,strong) NSString *feature;
@property (nonatomic,strong) NSString *firstcode;
@property (nonatomic)int     productId;//商品ID;
@property (nonatomic,strong) UIImage  *productImg;
@property (nonatomic,strong) NSString *isdel;
@property (nonatomic,strong) NSString *onsale;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *remerk;
@property (nonatomic,strong) NSString *saleamount;
@property (nonatomic,strong) NSString *saleexpired;
@property (nonatomic,strong) NSString *saleprice;
@property (nonatomic,strong) NSString *salestart;
@property (nonatomic)int     skuid;
@property (nonatomic,strong) NSString *skuname;
@property (nonatomic,strong) NSString *spec;
@end

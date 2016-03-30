//
//  StoreInfoRequest.h
//  rrcc_sj
//
//  Created by lawwilte on 7/28/15.
//  Copyright © 2015 ting liu. All rights reserved.
//  店铺管理网络请求

#import <Foundation/Foundation.h>

@interface StoreInfoRequest : NSObject
+(StoreInfoRequest*)Share;
//获取店铺信息
-(void)GetStoreInfo;

@end

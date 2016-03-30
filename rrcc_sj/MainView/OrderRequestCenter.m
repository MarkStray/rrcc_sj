//
//  OrderRequestCenter.m
//  rrcc_sj
//
//  Created by lawwilte on 7/23/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import "OrderRequestCenter.h"
#import "Orders.h"
#import "CoreDateManager.h"
#import "LoginViewController.h"

@interface OrderRequestCenter(){
    NSString *StrStatus;
}

@end

@implementation OrderRequestCenter
-(void)MulitThread:(id)Object{
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(GetOrderListRequest:) object:Object];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
}

#pragma mark 获得订单列表
-(void)GetOrderListRequest:(id)Object{
    
    StrStatus = [Object objectForJSONKey:@"status"];
    NSString *OrderListUrl = [NSString stringWithFormat:@"%@%@",BASEURL,ShopOrderList];
    if (![[Utility Share] userId]){
        return;
    }else{
        
        NSString *strUrl = [[RestHttpRequest SharHttpRequest] BackOrderListUrl:OrderListUrl InputResourceId:[[Utility Share] storeId] Inputstatus:[Object objectForJSONKey:@"OrderStatus"] InputStartTime:[Object objectForJSONKey:@"StartTime"] InputEndTime:[Object objectForJSONKey:@"EndTime"] InputPayLoad:@""];
        strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        [request setHTTPBody:nil];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation,id responseObject){
            NSDictionary *ResponseDic = responseObject;
            if ([[ResponseDic objectForJSONKey:@"Success"] isEqualToString:@"1"]){
                //获取更新后的时间，存入本地
                NSString *UpdateTime = [[Utility Share] GetNowTime];
                [[Utility Share] setUpdataTime:UpdateTime];
                [[Utility Share] saveUserInfoToDefault];
                [self insertOrdersInDb:[ResponseDic objectForJSONKey:@"CallInfo"]];
            }
            //如果报登陆出错码
            if ([[ResponseDic objectForJSONKey:@"ErrorCode"] isEqualToString:@"2002"]){
                //清空用户数据
                [[Utility Share] clearUserInfoInDefault];
                [[CoreDateManager Share] deleteData];//清空数据库
                //进入登录
                LoginViewController*LoginView = [[LoginViewController alloc] init];
                XHBaseNavigationController *LoginNav = [[XHBaseNavigationController alloc] initWithRootViewController:LoginView];
                LoginNav.navigationBar.translucent = NO;
                [AppDelegate Share].window.rootViewController = LoginNav;
            }
        } failure:^(AFHTTPRequestOperation *  operation, NSError * error) {
            if (error){
                [[Tools_HUD shareTools_MBHUD] alertTitle:[error localizedDescription]];
                NSNotification *notification = [NSNotification notificationWithName:@"NetWorkError" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                DLog(@"Error: %@", [error localizedDescription]);
            }
        }];
        [op start];
    }
}


#pragma mark 操作CoreData
//订单插入数据库
-(void)insertOrdersInDb:(NSMutableArray*)orderArray{
    
    NSMutableArray *SaveArray = [[NSMutableArray alloc] init];
    NSMutableArray *CodeArray = [self ReadAllArray];//订单号数组
    NSMutableArray *AllDataArray = [self ReadAllData];
    NSMutableArray *UnSaveArray = [[NSMutableArray alloc] init];//存放没有保存的数据
    for (NSMutableDictionary *orderEntity in orderArray){
        Orders *OrderInfo = [[Orders alloc] initWithDictionary:orderEntity];
        [SaveArray addObject:OrderInfo];
    }
    // 如果数据库里有数据
    if (SaveArray.count != 0){
        for (int  i = 0;i<SaveArray.count;i++){
            Orders *orderInfo = [SaveArray objectAtIndex:i];
            NSString *Code    = orderInfo.ordercode;
            NSString *Status  = orderInfo.status;
            //数据不存在,存入数据库,如果数据位新订单则存在数据库里,如果为新订单则发起本地通知
            if([CodeArray containsObject:Code] == NO){
                [UnSaveArray addObject:orderInfo];
            }
            //如果订单号存在数据库里
            if ([CodeArray containsObject:Code]){
                for (Orders *info in AllDataArray){
                    if ([Code isEqualToString:info.ordercode]&& [Status isEqualToString:info.status]== NO){
                        [[CoreDateManager Share] UpdateDate:orderInfo WithOrderCode:Code];
                    }
                }
            }
        }
        //如果数据不为空，则存入数据库
        if(UnSaveArray.count != 0){
            [[CoreDateManager Share] insertCoreData:UnSaveArray];
        }
    }
    //发起通知，更新界面
    if ([StrStatus isEqualToString:@"1"]){
        NSNotification *notification = [NSNotification notificationWithName:@"RefreshData" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        NSNotification *synchronizeNot = [NSNotification notificationWithName:@"synchronize" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:synchronizeNot];
    }
}


#pragma 操作CoreData
-(void)UpdateObject:(NSMutableArray*)OrderArray{
    NSMutableArray *SaveArray = [[NSMutableArray alloc] init];
    NSMutableArray *CodeArray = [self ReadAllArray];//订单号数组
    NSMutableArray *AllDataArray = [self ReadAllData];
    NSMutableArray *UnSaveArray = [[NSMutableArray alloc] init];//存放没有保存的数据
    for (NSMutableDictionary *orderEntity in OrderArray){
    Orders *OrderInfo = [[Orders alloc] initWithDictionary:orderEntity];
    [SaveArray addObject:OrderInfo];
    }
    // 如果数据库里有数据
    if (SaveArray.count != 0){
        for (int  i = 0;i<SaveArray.count;i++){
            Orders *orderInfo = [SaveArray objectAtIndex:i];
            NSString *Code    = orderInfo.ordercode;
            NSString *Status  = orderInfo.status;
        //数据不存在,存入数据库,如果数据位新订单则存在数据库里
        if([CodeArray containsObject:Code] == NO){
            [UnSaveArray addObject:orderInfo];
            }
            //如果订单号存在数据库里,状态不对
            if ([CodeArray containsObject:Code]){
                for (Orders *info in AllDataArray){
                    if ([Code isEqualToString:info.ordercode]&& [Status isEqualToString:info.status]== NO){
                        [self LocatNotification:Code OrderStatus:Status];
                        [self Speech:Code OrderStatus:Status];
                        [[CoreDateManager Share] UpdateDate:orderInfo WithOrderCode:Code];
                    }
                }
            }
        }
        //如果数据不为空，则存入数据库
        if(UnSaveArray.count != 0){
            [[CoreDateManager Share] insertCoreData:UnSaveArray];
        }
    }
    //发起通知，更新界面
    if ([StrStatus isEqualToString:@"1"]){
        NSNotification *notification = [NSNotification notificationWithName:@"RefreshData" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];

    }else{
    NSNotification *synchronizeNot = [NSNotification notificationWithName:@"synchronize" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:synchronizeNot];
    }
}

//读取所有的OrderCode
-(NSMutableArray*)ReadAllArray{
    NSMutableArray *DBList = [[CoreDateManager Share] readAllOrderData];
    NSMutableArray *CodeArray = [[NSMutableArray alloc] init];
    for (Orders *info  in DBList){
        [CodeArray addObject:info.ordercode];
    }
    return CodeArray;
}
//读取所有订单
-(NSMutableArray*)ReadAllData{
    NSMutableArray *AllDBArray = [[CoreDateManager Share] readAllOrderData];
    return AllDBArray;
}

//播放文字提示音
-(void)Speech:(NSString*)OrderCode OrderStatus:(NSString*)Status{
    NSString *SpeechString;
    NSMutableArray *Array = [[NSMutableArray alloc] init];
    for (int i = 0;i<OrderCode.length;i++){
        unichar  CharStr = [OrderCode characterAtIndex:i];//注意使用uniChar 
        NSString *StrChar = [NSString stringWithFormat:@"%C",CharStr];
        StrChar = [StrChar stringByAppendingString:@" "];
        [Array addObject:StrChar];
    }
    NSString *CodeStr  = [Array componentsJoinedByString:@""];
    self.Synthesizer = [[AVSpeechSynthesizer alloc] init];
    if ([Status isEqualToString:@"1"]){
        SpeechString = [NSString stringWithFormat:@"%@%@%@",@"您有一个新订单,订单号是 ",CodeStr,@" 请注意查看!"];
    }
    if ([Status isEqualToString:@"5"]){
        SpeechString = [NSString stringWithFormat:@"%@%@",@"用户已取消该订单,订单号是 ",CodeStr];
    }
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:SpeechString];
    //设置语言类别（不能被识别，返回值为nil）
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    //设置语速快慢
    utterance.rate *= AVSpeechUtteranceMinimumSpeechRate;
    //语音合成器会生成音频
    [self.Synthesizer speakUtterance:utterance];
}

//添加本地通知 ,有新的订单
//1为最新的订单,4为商户取消,5为用户取消
-(void)LocatNotification:(NSString *)OrderCode OrderStatus:(NSString*)Status{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置10秒之后
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:1];
    if (notification != nil){
        // 设置推送时间
        notification.fireDate = pushDate;
        // 设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = 0;
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        if ([Status isEqualToString:@"1"]){
        notification.alertBody = [NSString stringWithFormat:@"%@%@%@",@"您有新的订单,订单号是:",OrderCode,@"请注意查看!"];
        }
        if ([Status isEqualToString:@"4"]){
        notification.alertBody = [NSString stringWithFormat:@"%@%@",@"商户已取消该订单,订单号是:",OrderCode];
        }
        if ([Status isEqualToString:@"5"]){
        notification.alertBody = [NSString stringWithFormat:@"%@%@",@"用户已取消该订单,订单号是:",OrderCode];
        }
        //显示在icon上的红色圈中的数子
        notification.applicationIconBadgeNumber = 0;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name"forKey:@"key"];
        notification.userInfo = info;
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
    }
}


//获取开始时间
-(NSString*)startTime{
    NSString *lastWeekDay = [[[Utility Share] lastWeekDay]stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSMutableArray *AllDBArray = [[CoreDateManager Share] readAllOrderData];
    NSMutableArray *updateTimeArray = [[NSMutableArray alloc] init];
    for (Orders *orderInfo in AllDBArray){
        if (orderInfo.updatetime){
            [updateTimeArray addObject:orderInfo.updatetime];
        }
        NSString *insertTime = [[orderInfo.inserttime substringWithRange:NSMakeRange(0, 10)] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if ([insertTime integerValue] < [lastWeekDay integerValue]){
            //删除一周以前的订单
            [[CoreDateManager Share] deleteOrderWithInserTime:orderInfo.inserttime];
        }
    }
    //排序,取出最后的UpdateTime
    NSArray *sortArray = [updateTimeArray sortedArrayUsingSelector:@selector(compare:)];
    NSString *updateTime = [sortArray lastObject];
    return updateTime;
}

//根据状态获取订单列表
-(void)GetOrderList:(NSString*)OrderStatus Status:(NSString*)status{
    //配置状态和开始结束时间
    if ([status isEqualToString:@"1"]){
    NSString *TimeStart;
    if (![[Utility Share] UpdataTime]){
        TimeStart = [[Utility Share] DayBeforeYesterday];
    }else{
        TimeStart = [self startTime];
    }
    NSString *TimeEnd  = [[Utility Share] GetNowTime];
    NSDictionary *RequestDic = [NSDictionary dictionaryWithObjectsAndKeys:OrderStatus,@"OrderStatus",TimeStart,@"StartTime",TimeEnd,@"EndTime",status,@"status",nil];
        [self MulitThread:RequestDic];
        
    }else{
        
        NSString *TimeStart= [[Utility Share] DayBeforeYesterday];
        NSString *TimeEnd  = [[Utility Share] GetNowTime];
        NSDictionary *RequestDic = [NSDictionary dictionaryWithObjectsAndKeys:OrderStatus,@"OrderStatus",TimeStart,@"StartTime",TimeEnd,@"EndTime",status,@"status",nil];
        [self MulitThread:RequestDic];
    }
    
}


#pragma mark 获取店铺信息
-(void)GetStoreInfo{
    NSString *StoreUrl = [NSString stringWithFormat:@"%@%@",BASEURL,CustomerShopList];
    NSString *strUrl = [[RestHttpRequest SharHttpRequest] AppendPublickKey:StoreUrl InputResourceId:[[Utility Share] userId] InputPayLoad:@""];
    [[AppDelegate Share].manger GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *  operation, id responseObject){
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([[Dic objectForJSONKey:@"Success"]isEqualToString:@"1"]){
            //处理店铺信息，判断是否为空
            NSString *AdressStr = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"address"];
            NSString *Amount    = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"amount"];
            NSString *CloseTime = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"closetime"];
            NSString *StartTime = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"starttime"];
            NSString *StoreId   = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"id"];
            NSString *IsOpen    = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"isopen"];
            NSString *ShopName  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"shop_name"];
            NSString *SiteList  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"sitelist"];
            NSString *Status    = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"status"];
            NSString *deliverycost = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"deliverycost"];
            NSString *freedelivery = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"freedelivery"];
            NSString *minorder  = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"minorder"];
            NSString *provinceid = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"provinceid"];
            NSString *regionid   = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"regionid"];
            NSString *regionname = [[[Dic objectForJSONKey:@"CallInfo"] objectAtIndex:0] objectForJSONKey:@"regionname"];
            if (![SiteList notEmptyOrNull]){
                SiteList = @"";
            }
            NSMutableDictionary *StoreDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:AdressStr,@"address",Amount,@"amount",CloseTime,@"closetime",StartTime,@"starttime",StoreId,@"id",IsOpen,@"isopen",ShopName,@"shop_name",SiteList,@"sitelist",Status,@"status",deliverycost,@"deliverycost",freedelivery,@"freedelivery",minorder,@"minorder",provinceid,@"provinceid",regionid,@"regionid",regionname,@"regionname",nil];
            [[Utility Share] setStoreDic:StoreDic];
            [[Utility Share] setStoreId:Dic[@"CallInfo"][0][@"id"]];
            [[Utility Share] setOpenStatus:Dic[@"CallInfo"][0][@"isopen"]];
            [[Utility Share] saveUserInfoToDefault];
            [self GetOrderList:@"0" Status:@"1"];
        }else{
            //清空用户数据
            [[Utility Share] clearUserInfoInDefault];
            [[CoreDateManager Share] deleteData];//清空数据库
            //进入登录
            LoginViewController*LoginView = [[LoginViewController alloc] init];
            XHBaseNavigationController *LoginNav = [[XHBaseNavigationController alloc] initWithRootViewController:LoginView];
            LoginNav.navigationBar.translucent = NO;
            [AppDelegate Share].window.rootViewController = LoginNav;
        }
    }
    failure:^(AFHTTPRequestOperation *  operation, NSError *  error){
                            }];
}



@end

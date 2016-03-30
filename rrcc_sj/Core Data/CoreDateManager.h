//
//  OrderManage.h
//  rrcc_sj
//
//  Created by lawwilte on 15/7/16.
//  Copyright © 2015年 ting liu. All rights reserved.
//  Order CoreData Manager


#import <Foundation/Foundation.h>
#import "Orders.h"
#define TableName @"OrderModel"

@interface CoreDateManager : NSObject

+(CoreDateManager*)Share;//单例
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//CoreData 方法
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(NSManagedObjectContext*)newPrivateContext;

//插入数据
- (void)insertCoreData:(NSMutableArray*)dataArray;
//删除
- (void)deleteData;
//删除InsertTime 大于一周的
-(void)deleteOrderWithInserTime:(NSString*)orderInserTime;
//根据OrderCode 更新
-(void)UpdateDate:(Orders*)Info WithOrderCode:(NSString*)OrderCode;
-(void)UpdateOrderInfo:(NSMutableDictionary *)Info WithOrderCode:(NSString *)OrderCode;
//分页查询
-(NSMutableArray*)FliterFromDb:(int)pageSize andOffSet:(int)currentPage;
//读取全部数据
-(NSMutableArray*)readAllOrderData;
//根据谓词查询
-(NSMutableArray*)FliterFromDb:(NSPredicate*)FetchPredicate;
//-(NSMutableArray*)FliterFromDbBySvTime:(NSPredicate*)FetchPredicate;



@end

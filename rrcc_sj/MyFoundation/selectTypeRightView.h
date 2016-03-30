//
//  selectTypeRightView.h
//  ZKwwlk
//
//  Created by junseek on 14-7-23.
//  Copyright (c) 2014年 五五来客. All rights reserved.
//

#import <UIKit/UIKit.h>
@class selectTypeRightView;
@protocol selectTypeRightViewViewDelegate <NSObject>

@optional  //可选
-(void)selectTypeRightViewCell:(selectTypeRightView *)sv object:(NSInteger )index ItemNamr:(NSString*)name;

@end
@interface selectTypeRightView : UIView


-(id)initWithFrame:(CGRect)frame;
- (void)show;
- (void)hidden;

//strType
@property (nonatomic, weak) id<selectTypeRightViewViewDelegate> delegateType;
@property (assign,nonatomic) BOOL showHidden;
@property (strong,nonatomic) NSString *strType;
@property (strong,nonatomic) NSArray *DataArray;
@property (strong,nonatomic) NSArray *IdArray;
@property (assign,nonatomic) NSInteger indexS;
@property (assign,nonatomic) NSMutableDictionary *DataDic;
@property (strong,nonatomic) NSMutableArray *Allary;

@property (strong,nonatomic) NSMutableArray *SkuIdArrary;//商品SkuID
@property (strong,nonatomic) NSMutableArray *SkuNameArray;//商品名称
@property (strong,nonatomic) NSMutableDictionary *SkuDic;//商品字典
@end

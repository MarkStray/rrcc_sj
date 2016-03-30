//
//  UniteSelectView.h
//  rrcc_sj
//
//  Created by lawwilte on 15-6-23.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UniteSelectView;
@protocol UniteSelctViewDelegate <NSObject>
@optional
-(void)selectUniteViewCell:(UniteSelectView*)sv object:(NSInteger)index;
@end

@interface UniteSelectView : UIView

-(id)initWithFrame:(CGRect)frame;
-(void)show;
-(void)hidden;

@property (nonatomic, weak) id<UniteSelctViewDelegate> delegateType;
@property (assign,nonatomic) BOOL showHidden;
@property (strong,nonatomic) NSString *strType;
@property (strong,nonatomic) NSArray *DataArray;
@end

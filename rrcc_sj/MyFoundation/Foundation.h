//
//  Foundation.h
//  beta1
//
//  Created by liuting ray on 10-12-29.
//  Copyright   All rights reserved.
//
#import "Foundation_defines.h"
//商户端接口

//#define   BASEURL @"http://rest.2b.renrencaichang.com/"
//#define BASEURL @"http://rest.saas.renrencaichang.com"
#define BASEURL @"http://rest.dev.renrencaichang.com/"
//#define BASEURL @"http://rest.test.renrencaichang.com/"
//#define BASEURL @"http://rest.renrencaichang.com/"


//城市列表
#define CityList                @"CityList"
//商户登录
#define CustomerLogin           @"Customer"
//获取验证码和验证验证码
#define  Captcha                @"CustomerCaptcha"
//注册填写资料
#define  Profile                @"CustomerProfile/"
//图片上传
#define Photo                   @"CustomerPhoto/"
// 修改密码
#define Password                @"CustomerPassword/"
//下载商户店铺信息
#define CustomerShopList        @"CustomerShopList/"
//更改店铺地址
#define ShopAddress             @"ShopAddress/"
//更改配送规则
#define ShopDeliveryRule        @"ShopDeliveryRule/"
//更改配送小区状态，删除配送小区，添加配送小区,单个更新
#define ShopDeliverySite        @"ShopDeliverySite/"
//获取配送小区列表 多个更新
#define ShopDeliverySiteList    @"ShopDeliverySiteList/"
//获取未配送小区的列表
#define ShopSiteList            @"ShopSiteList/"
//修改联系人信息
#define ShopContact             @"ShopContact/"
// 修改营业时间
#define ShopOpeningDatetime     @"ShopOpeningDatetime/"
  //更改店铺营业状态
#define ShopOpening             @"ShopOpening/"
//获取店铺订单列表
#define ShopOrderList           @"ShopOrderList/"
//获取订单详情
#define OrderDetails            @"ShopOrderDetails/"
//获得用户评价信息
#define ShopAppraiseList        @"ShopAppraiseList/"
//读取产品列表
#define ShopProductList         @"ShopProductList/"
//操作订单
#define ShopOrder               @"ShopOrder/"
//更新产品
#define RefreshProducList       @"ShopProductList/"
//商品管理
#define ShopProduct             @"ShopProduct/"
//账单管理
#define ShopBillList            @"ShopBillList/"
//满减管理  获取满减列表
#define ShopDiscountList        @"ShopDiscountList/"
//创建和删除满减
#define ShopDiscount            @"ShopDiscount/"
//获取赠品列表
#define ShopGiftList            @"ShopGiftList/"
//赠品管理
#define ShopGift                @"ShopGift/"
//获取促销列表
#define ShopSaleList            @"ShopSaleList/"
//促销管理
#define ShopSale                @"ShopSale/"
//获取版本信息
#define CustomerApp             @"CustomerIosAPP?key=ios&version="
//提交支付宝账号
#define CustomerAlipay          @"CustomerAlipay/"
//开通微店
#define CustomerRshop           @"CustomerRshop/"
//更新商户推送ID
#define CustomerPushId          @"CustomerPushId/"



#define kVersion7 ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
#define rgbblue RGBCOLOR(71, 178, 226)


#define CN 1
#define UI_language(cn,us) CN?cn:us

#define UI_btn_back CN?@"返回":@"back"

#define UI_btn_search CN?@"搜索":@"Search"

#define UI_btn_upload CN?@"上传":@"Upload"
#define UI_btn_submit CN?@"提交":@"Submit"
#define UI_btn_cancel CN?@"取消":@"cancel"
#define UI_btn_confirm CN?@"确定":@"OK"
#define UI_btn_delete CN?@"删除":@"Delete"
#define UI_tips_load CN?@"正在加载...":@"Loading..."

#define alertErrorTxt @"服务器异常"


//----------------------登录短信---------------------




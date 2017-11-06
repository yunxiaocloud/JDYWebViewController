//
//  NJKWebViewController.h
//  JiudouyuApp
//
//  Created by 薛晶锦 on 2017/11/6.
//  Copyright © 2017年 张一力. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    LOADUrl,
    LOADHtml
}LOADWEBType;

typedef void(^JSLogicBlock)(NSString * jsName);
@interface NJKWebViewController : UIViewController

@property(nonatomic,copy)dispatch_block_t ClickBackBtnBlock; //点击返回键关闭本页面的响应事件
@property(nonatomic,copy)dispatch_block_t ClickBackBtnDirectBlock; //点击返回键不关闭页面的响应事件
@property(nonatomic,copy)JSLogicBlock jumpLogic;

@property(nonatomic,assign)LOADWEBType webLoadType;
@property(nonatomic,strong)NSString * loadTypeHtmlString;
@property(nonatomic,copy)NSString * url;

@end

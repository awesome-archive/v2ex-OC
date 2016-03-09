//
//  WTMeViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/30.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WTMeMessageType){

    WTMeMessageTypeTopic = 0,                     // 话题
    WTMeMessageTypeReply,                      // 回复别人
    WTMeMessageTypeNotification,          // 回复自己
    WTMeMessageTypeCollection,                // 收藏
};

@interface WTMeViewController : UIViewController

/** 用户姓名 */
@property (nonatomic, strong) NSString         *username;

@end

//
//  WTAccountParam.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/20.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTAccountParam : NSObject
/** 用户名 */
@property (nonatomic, strong) NSString          *u;
/** 密码 */
@property (nonatomic, strong) NSString          *p;

@property (nonatomic, strong) NSString          *once;

@property (nonatomic, strong) NSString          *next;
@end

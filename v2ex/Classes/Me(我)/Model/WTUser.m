//
//  WTUser.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/24.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTUser.h"
#import "WTAccount.h"
@implementation WTUser

- (BOOL)isLoginUser
{
   // if ([[WTAccount shareAccount].usernameOrEmail isEqualToString: self.username])
     //   return true;
    return false;
}

@end

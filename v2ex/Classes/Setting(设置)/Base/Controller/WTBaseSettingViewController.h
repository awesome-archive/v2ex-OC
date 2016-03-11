//
//  WTBaseSettingViewController.h
//  v2ex
//
//  Created by 无头骑士 GJ on 16/2/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTGroupItem.h"
#import "WTSettingCell.h"
@interface WTBaseSettingViewController : UITableViewController
/** 描述tableView一共有多少组 */
@property (nonatomic, strong) NSMutableArray           *groups;
@end

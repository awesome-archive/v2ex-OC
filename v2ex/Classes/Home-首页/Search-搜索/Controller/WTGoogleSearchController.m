//
//  WTGoogleSearchController.m
//  v2ex
//
//  Created by gengjie on 16/9/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTGoogleSearchController.h"

@implementation WTGoogleSearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchController.searchResultsUpdater = self;
}

@end

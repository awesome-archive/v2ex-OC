//
//  main.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/1/13.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <tingyunApp/NBSAppAgent.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        [NBSAppAgent startWithAppID:@"990f636ebc0c431f811cff9c029416b2"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

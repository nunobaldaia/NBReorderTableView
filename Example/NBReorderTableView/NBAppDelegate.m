//
//  NBAppDelegate.m
//  NBReorderTableView
//
//  Created by CocoaPods on 02/03/2015.
//  Copyright (c) 2014 Nuno Baldaia. All rights reserved.
//

#import "NBAppDelegate.h"
#import "NBViewController.h"

@implementation NBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = [NBViewController new];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

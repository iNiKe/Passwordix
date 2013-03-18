//
//  MainViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/3/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AITabBarController.h"

@interface MainViewController : UIViewController {
	AITabBarController * _tabBarController;
}

@property(nonatomic, retain) AITabBarController * _tabBarController;

@end

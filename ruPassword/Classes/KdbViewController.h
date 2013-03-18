//
//  KdbViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/6/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KdbLib.h>
#import "AITabBarController.h"
#import "ModalDelegate.h"

@interface KdbViewController : UIViewController<UITabBarControllerDelegate, UIAlertViewDelegate, ModalDelegate> {
	AITabBarController * _tabBarController;
	id<KdbGroup> _group;
}

@property(nonatomic, retain) AITabBarController * _tabBarController;
@property(nonatomic, readonly) id<KdbGroup> _group;

-(id)initWithGroup:(id<KdbGroup>)group;

@end

//
//  AppDelegate.h
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileManager.h"
#import "KdbViewController.h"
#import "PasswordViewController.h"
#import "AITabBarController.h"
#import "ModalDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, ModalDelegate>
{
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AITabBarController *tabBarController;
@property (strong, nonatomic) FileManager *fileManager;
@property (nonatomic, strong) KdbViewController *kdbView;
@property (nonatomic, unsafe_unretained) id currentViewController;


- (void)showMainView;
- (void)showKdb;
- (BOOL)isEditable;

@end

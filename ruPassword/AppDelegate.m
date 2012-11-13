//
//  AppDelegate.m
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import <sys/utsname.h>
#import "iRate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DLog(@"bundlePath = %@", [[NSBundle mainBundle] bundlePath]);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2;

    BOOL iPadDevice = ( ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) );

    if (iPadDevice)
    {
        viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController_iPad" bundle:nil];
        viewController2 = [[SecondViewController alloc] initWithNibName:@"SecondViewController_iPad" bundle:nil];
    } 
    else
    {
        viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil];
        viewController2 = [[SecondViewController alloc] initWithNibName:@"SecondViewController_iPhone" bundle:nil];
    }
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, nil];

/*
    if ( [self.window respondsToSelector:@selector(setRootViewController:)] )
        self.window.rootViewController = self.tabBarController;
    else
*/
    [self.window addSubview: self.tabBarController.view];
    [self.window makeKeyAndVisible];
    
/*
    NSString *model= [[UIDevice currentDevice] model];
    NSString *systemName= [[UIDevice currentDevice] systemName];
    NSString *systemVersion= [[UIDevice currentDevice] systemVersion];
    struct utsname u;
	uname(&u);
    NSLog(@"Model = %@", model);
    NSLog(@"systemName = %@", systemName);
    NSLog(@"systemVersion = %@", systemVersion);
    NSLog(@"uname: sysname = %s\n nodename = %s\n release = %s\n version = %s\n machine = %s", u.sysname, u.nodename, u.release, u.version, u.machine);
*/
    
	[iRate sharedInstance].appStoreID = APP_ID;
#ifdef DEBUG
//	[iRate sharedInstance].debug = YES;
#else
//	[iRate sharedInstance].debug = NO;
#endif
    [iRate sharedInstance].promptAtLaunch = YES;
    
    [iRate sharedInstance].cancelButtonLabel = NSLocalizedString(@"RATER_CANCEL_BUTTON", nil);
    [iRate sharedInstance].messageTitle = [NSString stringWithFormat:NSLocalizedString(@"RATER_MESSAGE_TITLE", nil), [iRate sharedInstance].applicationName];
    [iRate sharedInstance].message = [NSString stringWithFormat:NSLocalizedString(@"RATER_MESSAGE", nil), [iRate sharedInstance].applicationName];
    [iRate sharedInstance].rateButtonLabel = NSLocalizedString(@"RATER_RATE_BUTTON", nil);
    [iRate sharedInstance].remindButtonLabel = NSLocalizedString(@"RATER_RATE_LATER", nil);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
//    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end

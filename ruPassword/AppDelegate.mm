//
//  AppDelegate.m
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import <sys/utsname.h>
#import <Dropbox/Dropbox.h>
#import "AppDelegate.h"
#import "GeneratorViewController.h"
#import "ConverterViewController.h"
#import "iRate.h"
#import "FileViewController.h"
#import "Flurry.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize fileManager = _fileManager;
@synthesize kdbView = _kdbView;
@synthesize currentViewController = _currentViewController;

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception)
{
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
    NSLog(@"Uncaught Exception: %@",exception);
}

- (void)iRateSetup
{
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
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"S1QQQXXXT46PLEIYG6RZ"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    DLog(@"bundlePath = %@", [[NSBundle mainBundle] bundlePath]);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	_fileManager = [[FileManager alloc] init];

    UIViewController *viewController1, *viewController2;

    BOOL iPadDevice = ( ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) );

    if (iPadDevice)
    {
        viewController1 = [[GeneratorViewController alloc] initWithNibName:@"GeneratorViewController_iPad" bundle:nil];
        viewController2 = [[ConverterViewController alloc] initWithNibName:@"ConverterViewController_iPad" bundle:nil];
    }
    else
    {
        viewController1 = [[GeneratorViewController alloc] initWithNibName:@"GeneratorViewController_iPhone" bundle:nil];
        viewController2 = [[ConverterViewController alloc] initWithNibName:@"ConverterViewController_iPhone" bundle:nil];
    }
    
	FileViewController *fileView = [[FileViewController alloc] init];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:fileView];
    self.tabBarController = [[AITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:nav1, nav2, nav3, nil];
    [Flurry logAllPageViews:self.tabBarController];

    if ( [self.window respondsToSelector:@selector(setRootViewController:)] )
        self.window.rootViewController = self.tabBarController;
    else
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
    [self iRateSetup];
    
    // DropBox setup
	DBAccountManager *accountManager =
    [[DBAccountManager alloc] initWithAppKey:@"6zbvxmxiobvfnon" secret:@"7v62hz6bw54nq6l"];
	[DBAccountManager setSharedManager:accountManager];
    
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

- (void)dismissModalViewCancel:(id)controller
{
    NSLog(@"%@",controller);
}

- (void)dismissModalViewOK:(id)controller
{
    NSLog(@"%@",controller);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

	if ([_currentViewController isKindOfClass:[KdbViewController class]])
    {
//		[((UIViewController *)_currentViewController).view removeFromSuperview];
		
		PasswordViewController *lockWindow = [PasswordViewController controllerWithDelegate:self fileName:_fileManager.filename remote:NO];
		lockWindow._isReopen = YES;
		
		_currentViewController = lockWindow;
//		[self.window addSubview:lockWindow.view];
        self.window.rootViewController = lockWindow;
	}
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

- (void)showKdb
{
	if (![_currentViewController isKindOfClass:[KdbViewController class]])
    {
		[((UIViewController *)_currentViewController).view removeFromSuperview];
		id<KdbReader> kdbReader = _fileManager.kdbReader;
		
		if (!_kdbView) {
			_kdbView = [[KdbViewController alloc] initWithGroup:[[kdbReader getKdbTree] getRoot]];
		}
//	 	NSLog(@"%@ %@",self.tabBarController.selectedViewController,self.tabBarController.selectedViewController.navigationController);
		_currentViewController = _kdbView;
//        [((UINavigationController *)self.tabBarController.selectedViewController) pushViewController:_kdbView animated:YES];

        self.window.rootViewController = _kdbView;

//		[self.window addSubview:((UIViewController *)_currentViewController).view];
		
		CATransition *animation = [CATransition animation];
		[animation setDuration:0.5];
		[animation setType:kCATransitionFade];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[[self.window layer] addAnimation:animation forKey:@"SwitchToKdbView"];
	}
}

- (void)showMainView
{
//	if ([_currentViewController isKindOfClass:[KdbViewController class]])
    {
//		[((UIViewController *)_currentViewController).view removeFromSuperview];
        self.window.rootViewController = _tabBarController;
		_fileManager.kdbReader = nil;
		_kdbView = nil;
		_currentViewController = nil;
        
		
		CATransition *animation = [CATransition animation];
		[animation setDuration:0.5];
		[animation setType:kCATransitionFade];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[[self.window layer] addAnimation:animation forKey:@"SwitchToMainView"];
	}
}

- (BOOL)isEditable
{
	return _fileManager.editable;
}

@end

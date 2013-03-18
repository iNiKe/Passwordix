//
//  KdbViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/6/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "KdbViewController.h"
#import "GroupViewController.h"
#import "EntrySearchViewController.h"
#import "OptionViewController.h"
#import "DummyViewController.h"


@implementation KdbViewController
@synthesize _tabBarController;
@synthesize _group;

- (id)initWithGroup:(id<KdbGroup>)group
{
	if ((self = [super init]))
    {
		_group = group;
	}
	return self;
}

- (void)dismissModalViewCancel:(id)controller
{
    
}

- (void)dismissModalViewOK:(id)controller
{
    
}

- (void)loadView
{
	//set the rootview
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = contentView;
	
	//the group view	
	GroupViewController * groupView = nil;
	if ([MyAppDelegate.fileManager getKDBVersion]==KDB_VERSION1)
    {
		groupView = [[GroupViewController alloc] initWithGroup:_group delegate:self];
		groupView._isRoot = YES;
	}
    else
		groupView = [[GroupViewController alloc] initWithGroup:(id<KdbGroup>)[[_group getSubGroups]objectAtIndex:0] delegate:self];
	
	UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:groupView];
	
	if (groupView._isRoot)
    { //KDB1
		NSString * filename = MyAppDelegate.fileManager.filename;
		if ([filename hasSuffix:@".kdb"])
			groupView.navigationItem.title = [filename substringToIndex:[filename length]-4];
		else
			groupView.navigationItem.title = filename;
	}
	
	groupView.tabBarItem.image = [UIImage imageNamed:@"passwords"];
	groupView.tabBarItem.title = NSLocalizedString(@"Passwords", @"Passwords");
	
	//the search view controller
	EntrySearchViewController * searchView = [[EntrySearchViewController alloc] init];
	UINavigationController * nav2 = [[UINavigationController alloc] initWithRootViewController:searchView];
	searchView._group = groupView._group;
	searchView.navigationItem.title = NSLocalizedString(@"Search", @"Search");
	
	searchView.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
	
	//the option view controller
	OptionViewController *optionView = [[OptionViewController alloc] init];
	UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:optionView];
	optionView.navigationItem.title = NSLocalizedString(@"Change Password", @"Change Password");
	
	optionView.tabBarItem.image = [UIImage imageNamed:@"options"];
	optionView.tabBarItem.title = NSLocalizedString(@"Options", @"Options"); 
	
	
	//a dummy view controller
	DummyViewController *dummy = [[DummyViewController alloc] init];
	dummy.tabBarItem.image = [UIImage imageNamed:@"files"];
	dummy.tabBarItem.title = NSLocalizedString(@"KDB Files", @"KDB Files");

	//the tab bar
	_tabBarController = [[AITabBarController alloc] init];
	_tabBarController.delegate = self;
	NSArray *controllers = [NSArray arrayWithObjects:nav, nav2, nav3, dummy, nil];
	_tabBarController.viewControllers = controllers;
    [Flurry logAllPageViews:_tabBarController];
	self.hidesBottomBarWhenPushed = YES;
    self.navigationController.navigationBarHidden = YES;
	[self.view addSubview:_tabBarController.view];
	
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
	if (buttonIndex)
    {
		[MyAppDelegate showMainView];
	}
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if([viewController isMemberOfClass:[DummyViewController class]])
    {
		UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Closing File", @"Closing File") 
															message:NSLocalizedString(@"Are you sure you want to leave the password file?", @"Close file confirmation")
														   delegate:self cancelButtonTitle:NSLocalizedString(@"No", "No")
												  otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];		
		[alertView show];
		return NO;
	}
    else
		return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end

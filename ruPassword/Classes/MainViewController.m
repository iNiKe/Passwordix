//
//  MainViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/3/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "MainViewController.h"
#import "FileViewController.h"
#import "SettingViewController.h"

@implementation MainViewController
@synthesize _tabBarController;

- (void)loadView
{
	//set the rootview
	UIView * contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view = contentView;
	
	//the file view	
	FileViewController * fileView = [[FileViewController alloc] init];
	UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:fileView];
	UINavigationItem * navItem = [[nav navigationBar].items objectAtIndex:0];
	navItem.title = NSLocalizedString(@"KeePass Files", @"KeePass Files");
	
	fileView.tabBarItem.image = [UIImage imageNamed:@"files"];
	fileView.tabBarItem.title = NSLocalizedString(@"KDB Files", @"KDB Files");
	
	UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:fileView action:@selector(addFile:)];
	navItem.leftBarButtonItem = addButton;

/*
	//the about view
	AboutViewController * aboutView = [[AboutViewController alloc]initWithStyle:UITableViewStyleGrouped];
	aboutView.tabBarItem.image = [UIImage imageNamed:@"about"];
	aboutView.tabBarItem.title = NSLocalizedString(@"About", @"About");
*/	
	//the tab bar
	_tabBarController = [[AITabBarController alloc] init];
//	NSArray * controllers = [NSArray arrayWithObjects:nav, aboutView, nil];
	NSArray *controllers = [NSArray arrayWithObjects:nav, nil];
	_tabBarController.viewControllers = controllers;
		
	[self.view addSubview:_tabBarController.view];	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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

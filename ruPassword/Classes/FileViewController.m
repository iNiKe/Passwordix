//
//  FileViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/3/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "FileViewController.h"
#import "FileManager.h"
#import "TKLabelTextFieldCell.h"
#import "NewLocalFileViewController.h"
#import "NewRemoteFileViewController.h"
#import "PasswordViewController.h"
#import "RenameFileViewController.h"
#import "RenameRemoteFileViewController.h"
#import "FileUploadViewController.h"

#define KDB1_SUFFIX ".kdb"
#define KDB2_SUFFIX ".kdbx"

#define NEW_FILE_BUTTON 0
#define IMPORT_DESKTOP_BUTTON 1
#define IMPORT_WEBSERVER_BUTTON 2

@interface FileViewController(PrivateMethods)

- (void)newFile;
- (void)downloadFile;
- (void)uploadFile;

@end

@implementation FileViewController
@synthesize _rowToDelete;

- (id)init
{
	if ((self = [super initWithStyle:UITableViewStylePlain]))
    {
        _files = [[NSMutableArray alloc] initWithCapacity:4];
        _remoteFiles = [[NSMutableArray alloc] initWithCapacity:4];
        [MyAppDelegate.fileManager getKDBFiles:_files];
        [MyAppDelegate.fileManager getRemoteFiles:_remoteFiles];
        self.tabBarItem.image = [UIImage imageNamed:@"files"];
        self.tabBarItem.title = NSLocalizedString(@"Passwords", nil);
    }
	return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFile:)];
	self.navigationItem.leftBarButtonItem = addButton;
}

#pragma mark -
#pragma mark Table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_files count] + [_remoteFiles count];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < [_files count])
    {
		RenameFileViewController *renameFile = [RenameFileViewController controllerWithDelegate:self];
		renameFile._filename = [_files objectAtIndex:indexPath.row];
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:renameFile];
		[self presentModalViewController:nav animated:YES];		
	}
    else
    {
		RenameRemoteFileViewController *renameFile = [RenameRemoteFileViewController controllerWithDelegate:self];
		renameFile._name = [_remoteFiles objectAtIndex:indexPath.row - [_files count]];
		renameFile._url = [MyAppDelegate.fileManager getURLForRemoteFile:renameFile._name];
		UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:renameFile];
		[self presentModalViewController:nav animated:YES];		
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileViewCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.detailTextLabel.text = nil;
	if (indexPath.row<[_files count]){ //local files
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		NSString * filename = [_files objectAtIndex:indexPath.row];
		UIImageView * iv = cell.imageView;
        NSDictionary *info = [FileManager getKDBInfoFromFile:[FileManager getFullFileName:filename]];
        
		if([filename hasSuffix:@KDB1_SUFFIX]){
			iv.image = [UIImage imageNamed:@"kdb"];
			filename = [filename substringToIndex:[filename length]-4];
			cell.detailTextLabel.text = NSLocalizedString(@"KeePass 1.x",  @"KeePass 1.x");
		}else if ([filename hasSuffix:@KDB2_SUFFIX]){
			iv.image = [UIImage imageNamed:@"kdbx"];
			filename = [filename substringToIndex:[filename length]-5];
			cell.detailTextLabel.text = NSLocalizedString(@"KeePass 2.x",  @"KeePass 2.0");
		}else{
			iv.image = [UIImage imageNamed:@"unknown"];
		}
        if (info)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@) Cipher: %@",nil),[info objectForKey:@"KeePassVersion"],[info objectForKey:@"FileVersion"],[info objectForKey:@"Cipher"]];
        }
		cell.textLabel.text = filename;
	}else { //remote files
		//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		NSString * filename = [_remoteFiles objectAtIndex:indexPath.row-[_files count]];
		UIImageView * iv = cell.imageView;
		iv.image = [UIImage imageNamed:@"http"];
		cell.textLabel.text = filename;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
		self._rowToDelete = indexPath;
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
														message:NSLocalizedString(@"Continue to delete the file?", @"Erase file confirmation") delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];	
		[alert show];
	}
}
		   
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.editing)
    {
		PasswordViewController *passwordView = nil;
		if (indexPath.row<[_files count])
			passwordView = [PasswordViewController controllerWithDelegate:self fileName:[_files objectAtIndex:indexPath.row] remote:NO];
        else
			passwordView = [PasswordViewController controllerWithDelegate:self fileName:[_remoteFiles objectAtIndex:indexPath.row-[_files count]] remote:YES];
		if (passwordView)
        {
            [self.navigationController pushViewController:passwordView animated:YES];
//            [self presentModalViewController:passwordView animated:YES];
        }
	}
    else {
	}
}

- (void)newFile
{
	NewLocalFileViewController *newLocalFile = [NewLocalFileViewController controllerWithDelegate:self];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newLocalFile];
	[self presentModalViewController:nav animated:YES];
}

- (void)uploadFile
{
	FileUploadViewController *uploadFile = [FileUploadViewController controllerWithDelegate:self];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uploadFile];
	[self presentModalViewController:nav animated:YES];
}

- (void)downloadFile
{
	NewRemoteFileViewController *newRemoteFile = [NewRemoteFileViewController controllerWithDelegate:self];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newRemoteFile];
	[self presentModalViewController:nav animated:YES];
}

- (void)dismissModalViewCancel:(id)controller
{
    if ([controller isKindOfClass:[PasswordViewController class]])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (void)dismissModalViewOK:(id)controller
{
    if ([controller isKindOfClass:[PasswordViewController class]])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissModalViewControllerAnimated:YES];
	
	//we need to display the groups
	if ([controller isKindOfClass:[PasswordViewController class]]) {
		[MyAppDelegate showKdb];
	} else if ([controller isKindOfClass:[NewRemoteFileViewController class]]) {
		[MyAppDelegate.fileManager getRemoteFiles:_remoteFiles];
		[self.tableView reloadData];
	} else if ([controller isKindOfClass:[NewLocalFileViewController class]]) {
		[MyAppDelegate.fileManager getKDBFiles:_files];
		[self.tableView reloadData];
	} else if ([controller isKindOfClass:[RenameFileViewController class]]) {
		[MyAppDelegate.fileManager getKDBFiles:_files];
		[self.tableView reloadData];	
	} else if ([controller isKindOfClass:[RenameRemoteFileViewController class]]) {
		[MyAppDelegate.fileManager getRemoteFiles:_remoteFiles];
		[self.tableView reloadData];		
	} else if ([controller isKindOfClass:[FileUploadViewController class]]) {
		[MyAppDelegate.fileManager getKDBFiles:_files];
		[self.tableView reloadData];
	}
}

- (IBAction)addFile:(id)sender
{
	UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:nil delegate:self 
										   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil 
										   otherButtonTitles:NSLocalizedString(@"New KDB 1.0 File", @"New KDB 1.0 File"), 
															 NSLocalizedString(@"Upload From Desktop", @"Upload From Desktop"), 	
															 NSLocalizedString(@"Download From WWW", @"Download From WWW"), nil];
	[as showInView:MyAppDelegate.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
    {
		case NEW_FILE_BUTTON:{
			[self newFile];
			break;
		}
		case IMPORT_DESKTOP_BUTTON:{
			[self uploadFile];
			break;
		}
		case IMPORT_WEBSERVER_BUTTON:{
			[self downloadFile];
			break;
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==1&&_rowToDelete)
    {
		if(_rowToDelete.row < [_files count])
        {
			[MyAppDelegate.fileManager deleteLocalFile:[_files objectAtIndex:_rowToDelete.row]];
			[MyAppDelegate.fileManager getKDBFiles:_files];
		}
        else
        {
			[MyAppDelegate.fileManager deleteRemoteFile:[_remoteFiles objectAtIndex:_rowToDelete.row-[_files count]]];
			[MyAppDelegate.fileManager getRemoteFiles:_remoteFiles];			
		}
		self._rowToDelete = nil;
		[self.tableView reloadData];
	}
}

@end


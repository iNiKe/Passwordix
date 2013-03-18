//
//  PasswordViewController.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/8/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "PasswordViewController.h"
#import "TKLabelTextFieldCell.h"
#import "ActivityView.h"
#import "FileManagerOperation.h"
#import "SelectKeyFileViewController.h"

@interface PasswordViewController(PrivateMethods)
-(void)showError:(NSString *)message;
@end


@implementation PasswordViewController
@synthesize _filename;
@synthesize _isRemote;
@synthesize _isReopen;
@synthesize _ok;
@synthesize _cancel;
@synthesize _switch;
@synthesize _av;
@synthesize _password;
@synthesize _useCache;
@synthesize _rusername;
@synthesize _rpassword;
@synthesize _rdomain;
@synthesize _op;
@synthesize _keyFileCell;

+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate fileName:(NSString *)fileName remote:(BOOL)isRemote
{
    return [[PasswordViewController alloc] initWithFileName:fileName remote:isRemote delegate:delegate];
}

- (id)initWithFileName:(NSString *)fileName remote:(BOOL)isRemote delegate:(id<ModalDelegate>)delegate
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]))
    {
		_filename = fileName;
		_isRemote = isRemote;
        if (!_isRemote)
        {
            _keyFilename = [FileManager getFullFileName:[[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"key"]];
            BOOL isDir = NO;
            if (!([[NSFileManager defaultManager] fileExistsAtPath:_keyFilename isDirectory:&isDir] && !isDir))
                _keyFilename = nil;
        }
        self.hidesBottomBarWhenPushed = YES;
		_isReopen = NO;
		_isLoading = NO;
        _delegate = delegate;
		_av = [[ActivityView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	}
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];	
	[_password.field becomeFirstResponder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];	
	_password = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_password.selectionStyle = UITableViewCellSelectionStyleNone;
	_password.field.secureTextEntry = YES;
	_password.field.placeholder = NSLocalizedString(@"Master Password", @"Master Password");
	_password.field.returnKeyType = UIReturnKeyDone;
	_password.field.delegate = self;
	
	_rusername = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_rusername.selectionStyle = UITableViewCellSelectionStyleNone;
	_rusername.field.placeholder = NSLocalizedString(@"Name", @"Name");
	_rusername.field.autocorrectionType = UITextAutocorrectionTypeNo;
	_rusername.field.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	_rpassword = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_rpassword.selectionStyle = UITableViewCellSelectionStyleNone;
	_rpassword.field.secureTextEntry = YES;
	_rpassword.field.placeholder = NSLocalizedString(@"Password", @"Password");
	
	_rdomain = [[TKLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_rdomain.selectionStyle = UITableViewCellSelectionStyleNone;	
	_rdomain.field.placeholder = NSLocalizedString(@"Domain", @"Domain");
	
    _keyFileCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    _keyFileCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _keyFileCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _keyFileCell.textLabel.text = NSLocalizedString(@"Key file", nil);
    _keyFileCell.detailTextLabel.text = (_keyFilename) ? [_keyFilename lastPathComponent] : NSLocalizedString(@"<none>", nil);

	_useCache = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_useCache.textLabel.text = NSLocalizedString(@"Use cached file", @"Use cached file");
	_useCache.textLabel.font = [UIFont systemFontOfSize:17];
	_useCache.textLabel.textColor = [UIColor darkGrayColor];
	_useCache.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_switch = [[UISwitch alloc]initWithFrame:CGRectMake(195, 6, 94, 27)];
	_switch.on = YES;

	[_useCache.contentView addSubview:_switch];	
	
	//set the footer;
	UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0,0,320,44)]; 
	_ok = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_ok.frame = CGRectMake(11,16,143,35); 
	[_ok setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
	
	_cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_cancel.frame = CGRectMake(165, 16, 143, 35);
	[_cancel setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
	
	[container addSubview:_ok];
	[container addSubview:_cancel];
	
	[_cancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
	[_ok addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];	
	
	self.tableView.tableFooterView = container;
}

- (void)viewDidUnload
{
	self._password = nil;
	self._rusername = nil;
	self._rpassword = nil;
	self._rdomain = nil;
	self._useCache = nil;
	self._switch = nil;
    _delegate = nil;
	[super viewDidUnload];	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 1)
    {
		return NSLocalizedString(@"Server side authentication", @"Server side authentication");
	} else {
		return [NSLocalizedString(@"Password of File ", @"Password of File") stringByAppendingString:_filename];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isRemote ? 2 : 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
//		return _isRemote ? 2 : 1;
        return 2;
    else
		return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 0)
    {
		if ([indexPath row] == 0)
			return _password;
		else
        {
            if (_isRemote)
                return _useCache;
            else
                return _keyFileCell;
        }
	}
    else
    {
		switch ([indexPath row])
        {
			case 0:
				return _rusername;
			case 1:
				return _rpassword;
			case 2:
				return _rdomain;
		}
	}
	return nil;
}

- (void)dismissModalViewCancel:(id)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissModalViewOK:(id)controller
{
    if ([controller isKindOfClass:[SelectKeyFileViewController class]])
    {
        [self.navigationController popViewControllerAnimated:YES];
        _keyFilename = ((SelectKeyFileViewController *)controller).selectedFile;
        _keyFileCell.detailTextLabel.text = [_keyFilename lastPathComponent];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        SelectKeyFileViewController *controller = [SelectKeyFileViewController controllerWithDelegate:self];
        controller.selectedFile = _keyFilename;
        [self.navigationController pushViewController:controller animated:YES];
        NSLog(@"Select Key file");
        // TODO: Select Key file ViewController
    }
}

- (IBAction)cancelClicked:(id)sender
{
	if (!_isReopen)
        [_delegate dismissModalViewCancel:self];
	else
		[MyAppDelegate showMainView];
}

- (IBAction)okClicked:(id)sender
{
	if (!_isReopen)
    {
		_ok.enabled = _cancel.enabled = NO;
		if (_isLoading) return;
		_isLoading = YES;
		[self.view addSubview:_av];	
		if(!_op) _op = [[FileManagerOperation alloc] initWithDelegate:self];		
		_op._filename = _filename;				
		_op._password = _password.field.text;
//        _op._keyFile = @"/Users/nike/Desktop/hex.key";
//        _op._keyFile = @"/Users/nike/Desktop/NewDatabase.key";
//        _op._keyFile = @"/Users/nike/Desktop/KeePass-2.21-Setup.exe";
        _op._keyFile = _keyFilename;

		if (!self._isRemote)
        {
			[_op performSelectorInBackground:@selector(openLocalFile) withObject:nil];
		}
        else
        {
			_op._useCache = _switch.on;
			_op._username = _rusername.field.text;
			_op._userpass = _rpassword.field.text;
			_op._domain = _rdomain.field.text;
			[_op performSelectorInBackground:@selector(openRemoteFile) withObject:nil];
		}				
	}
    else
    { // it is reopen, we verify the password directly
		NSString * password = _password.field.text;
		if([password isEqualToString:MyAppDelegate.fileManager.password]){
			[MyAppDelegate showKdb];
		}else{
			[self showError:NSLocalizedString(@"Master password is not correct", @"Master password is not correct")];
		}
	}
}

- (void)fileOperationSuccess
{
	[_av removeFromSuperview];
    [_delegate dismissModalViewOK:self];
}

- (void)fileOperationFailureWithException:(NSException *)exception
{
	[_av removeFromSuperview];
	_ok.enabled = _cancel.enabled = YES;
	_isLoading = NO;
	
	if ([[exception name] isEqualToString:@"DecryptError"])
    {
		[self showError:NSLocalizedString(@"Master password is not correct", @"Master password is not correct")];
	}
    else if ([[exception name] hasPrefix:@"Unsupported"])
    {
		NSString * msg = [[NSString alloc]initWithFormat:NSLocalizedString(@"File is not supported (error code:%@)", @"Unsupported file"),[exception reason],nil];
		[self showError:msg];
	}
    else if ([[exception name] isEqualToString:@"DownloadError"])
    {
		[self showError:NSLocalizedString(@"Cannot download the file", @"Cannot download the file")];
	}
    else if ([[exception name] isEqualToString:@"RemoteAuthenticationError"])
    {
		[self showError:NSLocalizedString(@"Server authentication error", @"Server authentication error")];
	}
    else
    {
		NSString * msg = [[NSString alloc]initWithFormat:NSLocalizedString(@"Master password might not be correct (error code:%@)", @"Unknown error"),[exception reason],nil];
		[self showError:msg];
	}
}

- (void)showError:(NSString *)message
{
	UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil 
													message:message delegate:self
										  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
										  otherButtonTitles:nil];	
	[alert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self okClicked:_ok];
	return NO;
}

@end


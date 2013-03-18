//
//  FileViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/3/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface FileViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate, ModalDelegate>
{
	NSMutableArray * _files;
	NSMutableArray * _remoteFiles;
	NSIndexPath * _rowToDelete;
}

@property(nonatomic, strong) NSIndexPath * _rowToDelete;

- (IBAction)addFile:(id)sender;

@end

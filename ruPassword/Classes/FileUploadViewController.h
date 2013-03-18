//
//  FileUploadViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/21/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"

@interface FileUploadViewController : UITableViewController
{
	HTTPServer * _httpServer;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, strong) HTTPServer * _httpServer;

- (IBAction)doneClicked:(id)sender;
- (void)displayInfoUpdate:(NSNotification *) notification;
+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate;

@end

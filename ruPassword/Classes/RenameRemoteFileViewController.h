//
//  RenameRemoteFileViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/21/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface RenameRemoteFileViewController : UITableViewController
{
	NSString * _name;
	NSString * _url;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, retain) NSString * _name;
@property(nonatomic, retain) NSString * _url;

+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate;

@end

//
//  RenameFileViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/21/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RenameFileViewController : UITableViewController
{
	NSString * _filename;
    __unsafe_unretained id<ModalDelegate> _delegate;
}

@property(nonatomic, strong) NSString * _filename;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate;

@end

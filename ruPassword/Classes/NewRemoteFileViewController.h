//
//  NewRemoteFileViewController.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/5/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewRemoteFileViewController : UITableViewController
{
    __unsafe_unretained id<ModalDelegate> _delegate;
}

- (IBAction)cancelClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;
+ (id)controllerWithDelegate:(id<ModalDelegate>)delegate;

@end

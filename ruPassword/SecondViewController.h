//
//  SecondViewController.h
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SecondViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    UITextField *ruPass;
    UITextField *enPass;
    UISwitch *iMacSw;
    UIButton *ClipBtn;
    UIButton *rateButton;
    
    UILabel *ruPassLabel;
    UILabel *enPassLabel;
    UILabel *iMacLabel; 
    UILabel *transLabel; 
    UITextView *ruPassComment;
    UITextField *md5TextView;
    UITextField *sha1TextView;
    UITextField *transTextView;
    UITextField *currentTextField;
    UIScrollView *scrollView;
    UINavigationBar *navbar;
    
    UIView *view1;
    BOOL bannerIsVisible, iPadDevice;
}

@property (nonatomic, strong) IBOutlet UITextField *ruPass;
@property (nonatomic, strong) IBOutlet UITextField *enPass;
@property (nonatomic, strong) IBOutlet UISwitch *iMacSw;

@property (nonatomic, strong) IBOutlet UILabel *ruPassLabel;
@property (nonatomic, strong) IBOutlet UILabel *enPassLabel;
@property (nonatomic, strong) IBOutlet UILabel *iMacLabel;
@property (nonatomic, strong) IBOutlet UILabel *transLabel;
@property (nonatomic, strong) IBOutlet UITextView *ruPassComment;
@property (nonatomic, strong) IBOutlet UITextField *md5TextView;
@property (nonatomic, strong) IBOutlet UITextField *sha1TextView;
@property (nonatomic, strong) IBOutlet UITextField *transTextView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navbar;

@property (nonatomic, strong) IBOutlet UIView *view1;
@property (nonatomic, strong) IBOutlet UIButton *ClipBtn;
@property (nonatomic, strong) IBOutlet UIButton *rateButton;
@property (nonatomic, assign) BOOL bannerIsVisible, iPadDevice;

-(IBAction)ruChanged:(id)sender;
-(IBAction)enChanged:(id)sender;
-(IBAction)transChanged:(id)sender;
-(IBAction)copyToClip:(id)sender;
-(IBAction)rateApp:(id)sender;

@end

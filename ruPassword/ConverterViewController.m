//
//  SecondViewController.m
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import "ConverterViewController.h"
#import "iRate.h"
#import "GradientButton.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NKUtils.h"
#import "NSString+NKUtils.h"

#define IPAD_CONTENT_HEIGHT 549
#define IPHONE_CONTENT_HEIGHT 526

@implementation ConverterViewController

@synthesize ruPass, enPass, iMacSw, view1, ClipBtn, ruPassLabel, enPassLabel, iMacLabel, ruPassComment, md5TextField, sha1TextField, scrollView, transLabel, transTextField, navbar, rateButton;
@synthesize bannerIsVisible, iPadDevice;

- (void)sendInAppSMS:(NSString *)str
{
    [Flurry logEvent:@"Converter.Send.SMS"];
    if ( [[[UIDevice currentDevice] systemVersion] doubleValue ] >= 4.0 )
    {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = str;
            controller.recipients = nil; //[NSArray arrayWithObjects:@"12345678", @"87654321", nil];
            controller.messageComposeDelegate = self;
            [self presentModalViewController:controller animated:YES];
        }
    }
    else
    {
        copyStrToClipboard(str);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"sms:"]];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *message = @"";
    UIAlertView *v;
	switch (result)
    {
		case MessageComposeResultCancelled:
			message = @"Cancelled";
			break;
            
		case MessageComposeResultFailed:
            message = NSLocalizedString(@"Failed to Send SMS", @"Ошибка отправки СМС!");
            v = [[UIAlertView alloc] initWithTitle: [iRate sharedInstance].applicationName message: message delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
			break;
		case MessageComposeResultSent:
            
			break;
		default:
			break;
	}
    DLog(@"message = %@", message);
	[self dismissModalViewControllerAnimated:YES];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)sendEmail:(NSString *)pass
{
    DLog(@"notify Others");
    [Flurry logEvent:@"Converter.Send.Email"];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject: [iRate sharedInstance].applicationName];
    
    
    // Set up recipients
    /*NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
     NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
     NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
     
     [picker setToRecipients:toRecipients];
     [picker setCcRecipients:ccRecipients];
     [picker setBccRecipients:bccRecipients];*/
    
    // Attach an image to the email
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    //NSData *myData = [NSData dataWithContentsOfFile:path];
    //[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat: @"%@", pass];
    
    // html email
    [picker setMessageBody: emailBody isHTML: YES];
    
    if (picker != nil)
    {
        [self presentModalViewController: picker animated: YES];
    }
    else
    {
        DLog(@"Mail not configured on the device");
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController: (MFMailComposeViewController *) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError *) error
{
    NSString *message;
    UIAlertView *v;
    // Notifies users about errors associated with the interface
    switch (result) {
        case MFMailComposeResultCancelled:
            message = @"Result: canceled";
            break;
            
        case MFMailComposeResultSaved:
            message = @"Result: saved";
            break;
            
        case MFMailComposeResultSent:
            message = @"Sent Email OK";
            //v = [[UIAlertView alloc] initWithTitle:@"App Email" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[v show];
            //[v release];
            break;
            
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"Failed to Send Email", @"Ошибка отправки E-Mail!");
            v = [[UIAlertView alloc] initWithTitle: [iRate sharedInstance].applicationName message: message delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
            [v show];
            break;
            
        default:
            message = @"Result: not sent";
            break;
    }
    DLog(@"message = %@", message);
    // display an error
    [self dismissModalViewControllerAnimated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"buttonIndex = %i", buttonIndex);
    if ( buttonIndex == actionSheet.cancelButtonIndex ) return;
    NSString *s = enPass.text;
    switch (buttonIndex)
    {
        case 0:
            [Flurry logEvent:@"Converter.CopyToClipboard"];
            copyStrToClipboard(s);
            break;
        case 1:
            [self sendInAppSMS:s];
            break;
            
        case 2:
            [self sendEmail:s];
            break;
            
        default:
            break;
    }
}

- (void)hideKeyboard
{
    if ([ruPass isFirstResponder]) 
        [ruPass resignFirstResponder];
    else
        if ([enPass isFirstResponder])
            [enPass resignFirstResponder];
    [md5TextField resignFirstResponder];
    [sha1TextField resignFirstResponder];
    [transTextField resignFirstResponder];
}

-(IBAction)rateApp:(id)sender
{
    [Flurry logEvent:@"Converter.iRate.RateApp"];
    DLog(@"ratingsURL = %@", [[iRate sharedInstance] ratingsURL]);
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (IBAction)copyToClip:(id)sender
{
    [Flurry logEvent:@"Converter.CopyToClipboard"];
    [self hideKeyboard];
    copyStrToClipboard(enPass.text);
    [[iRate sharedInstance] logEvent:NO];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ClipBtn", @"Копировать") delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Отмена")
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:NSLocalizedString(@"Copy to Clipboard", @"Копировать"),
                                  NSLocalizedString(@"Send by SMS", @"Отправить по СМС..."),
                                  NSLocalizedString(@"Send by E-Mail", @"Отправить по E-Mail..."), nil];
    actionSheet.delegate = self;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)updateHash
{
    md5TextField.text = [enPass.text md5];
    sha1TextField.text = [enPass.text sha1];
}

- (void)checkCanClip
{
    ClipBtn.hidden = (enPass.text.length < 1 );
}

- (IBAction)ruChanged:(id)sender
{
    if ( iMacSw.isOn ) 
        enPass.text = [ruPass.text replaceFrom:rus1 to:eng1];
    else
        enPass.text = [ruPass.text replaceFrom:rus2 to:eng2];
    
    transTextField.text = [ruPass.text translit];
    
    [self checkCanClip];
    [self updateHash];
}

- (IBAction)enChanged:(id)sender
{
    if ( iMacSw.isOn ) 
        ruPass.text = [enPass.text replaceFrom:eng1 to:rus1];
    else
        ruPass.text = [enPass.text replaceFrom:eng2 to:rus2];
    transTextField.text = [ruPass.text translit];
    [self checkCanClip];
    [self updateHash];
}

- (IBAction)transChanged:(id)sender
{
//
}

#pragma mark - Edits & keyboard lifecycle

//---when a TextField view begins editing---
- (void)textFieldDidBeginEditing:(UITextField *)textFieldView
{  
    currentTextField = textFieldView;
}

//---when a TextField view is done editing---
- (void)textFieldDidEndEditing:(UITextField *) textFieldView
{  
    currentTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL editable;
    if ( (textField == md5TextField) || (textField == sha1TextField) || (textField == transTextField) )
    {
        editable = NO;
    }
    else
    {
        editable = YES;
    }
    return editable;
}

- (void)moveScrollViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
//    NSLog( @"moveScrollViewForKeyboard %i", up);
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    if ( [[[UIDevice currentDevice] systemVersion] doubleValue] < 3.2 )
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
        [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardEndFrame];
#pragma GCC diagnostic pop
    else
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = scrollView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newFrame.size.height -= ( keyboardFrame.size.height - appDelegate.tabBarController.tabBar.frame.size.height ) * (up? 1 : -1);
    scrollView.frame = newFrame;
    
    if ( up && currentTextField )
    {
        CGRect textFieldRect = [currentTextField frame];
        [scrollView scrollRectToVisible:textFieldRect animated:YES];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *) notification
{
    [self moveScrollViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    [self moveScrollViewForKeyboard:notification up:NO];
}

- (UITapGestureRecognizer *)tapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    return tap;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    [self hideKeyboard];
}

- (void)setupButtons
{
    [ClipBtn useImages:@"InstallButton" pressedImage:@"InstallButtonPressed" capWidth:3 capHeight:11];
    [rateButton useImages:@"InstallButton" pressedImage:@"InstallButtonPressed" capWidth:3 capHeight:11];
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    iPadDevice = ( ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) );
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Converter", @"Converter");
        self.tabBarItem.image = [UIImage imageNamed:@"converter"];
//        self.navigationItem.title = @"test";
//        self.tabBarItem.title = @"test";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)localize
{
    ruPassLabel.text = NSLocalizedString(@"ruPassLabel", @"ruPassLabel");
    enPassLabel.text = NSLocalizedString(@"enPassLabel", @"enPassLabel");
    ruPass.placeholder = NSLocalizedString(@"ruPassPlaceholder", @"ruPassPlaceholder");
    enPass.placeholder = NSLocalizedString(@"enPassPlaceholder", @"enPassPlaceholder");
    iMacLabel.text = NSLocalizedString(@"iMacLabel", @"iMacLabel");
    transLabel.text = NSLocalizedString(@"translit", @"translit");
    [ClipBtn setTitle:NSLocalizedString(@"ClipBtn", @"ClipBtn") forState:UIControlStateNormal];
    [rateButton setTitle:NSLocalizedString(@"rateButton", @"rateButton") forState:UIControlStateNormal];
    ruPassComment.text = NSLocalizedString(@"ruPassComment", @"ruPassComment");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupButtons];
    [self ruChanged:self];
    [self localize];
    [self updateScrollContentSize];
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2 )
    {
        self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    [self.view addGestureRecognizer:[self tapGesture]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //---registers the notifications for keyboard---
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window]; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //---removes the notifications for keyboard---
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateScrollContentSize];
    return YES;
}

- (BOOL)shouldAutorotate
{
    [self updateScrollContentSize];
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)updateScrollContentSize
{
    CGRect viewFrame = self.view.frame;
    CGFloat width = viewFrame.size.width;
    CGFloat height = viewFrame.size.height;
    if (iPadDevice)
    {
        scrollView.frame = CGRectMake(0, 44, width, height);
        [scrollView setContentSize:CGSizeMake(width, IPAD_CONTENT_HEIGHT)];
    }
    else
    {
        scrollView.frame = CGRectMake(0, 0, width, height);
        [scrollView setContentSize:CGSizeMake(width, IPHONE_CONTENT_HEIGHT)];
    }
}

@end

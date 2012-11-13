//
//  Appirater-Defs.h
//  ruPassword
//
//  Created by Nikita Galayko on 05.01.12.
//  Copyright (c) 2012 Galayko.ru. All rights reserved.
//

#ifndef ruPassword_Appirater_Defs_h
#define ruPassword_Appirater_Defs_h

/*
 Place your Apple generated software id here.
 */
#define APPIRATER_APP_ID				488134069

/*
 Your app's name.
 */
#define APPIRATER_APP_NAME				[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]

/*
 This is the message your users will see once they've passed the day+launches
 threshold.
 */
//#define APPIRATER_MESSAGE				[NSString stringWithFormat:@"If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", APPIRATER_APP_NAME]
#define APPIRATER_MESSAGE				[NSString stringWithFormat:NSLocalizedString(@"APPIRATER_MESSAGE", nil), APPIRATER_APP_NAME]

/*
 This is the title of the message alert that users will see.
 */
//#define APPIRATER_MESSAGE_TITLE			[NSString stringWithFormat:@"Rate %@", APPIRATER_APP_NAME]
#define APPIRATER_MESSAGE_TITLE         [NSString stringWithFormat:NSLocalizedString(@"APPIRATER_MESSAGE_TITLE", nil), APPIRATER_APP_NAME]

/*
 The text of the button that rejects reviewing the app.
 */
#define APPIRATER_CANCEL_BUTTON			NSLocalizedString(@"APPIRATER_CANCEL_BUTTON", nil)

/*
 Text of button that will send user to app review page.
 */
#define APPIRATER_RATE_BUTTON			[NSString stringWithFormat:NSLocalizedString(@"APPIRATER_RATE_BUTTON", nil), APPIRATER_APP_NAME]

/*
 Text for button to remind the user to review later.
 */
#define APPIRATER_RATE_LATER			NSLocalizedString(@"APPIRATER_RATE_LATER", nil)

/*
 Users will need to have the same version of your app installed for this many
 days before they will be prompted to rate it.
 */
#define APPIRATER_DAYS_UNTIL_PROMPT		30		// double

/*
 An example of a 'use' would be if the user launched the app. Bringing the app
 into the foreground (on devices that support it) would also be considered
 a 'use'. You tell Appirater about these events using the two methods:
 [Appirater appLaunched:]
 [Appirater appEnteredForeground:]
 
 Users need to 'use' the same version of the app this many times before
 before they will be prompted to rate it.
 */
#define APPIRATER_USES_UNTIL_PROMPT		20		// integer

/*
 A significant event can be anything you want to be in your app. In a
 telephone app, a significant event might be placing or receiving a call.
 In a game, it might be beating a level or a boss. This is just another
 layer of filtering that can be used to make sure that only the most
 loyal of your users are being prompted to rate you on the app store.
 If you leave this at a value of -1, then this won't be a criteria
 used for rating. To tell Appirater that the user has performed
 a significant event, call the method:
 [Appirater userDidSignificantEvent:];
 */
#define APPIRATER_SIG_EVENTS_UNTIL_PROMPT	-1	// integer

/*
 Once the rating alert is presented to the user, they might select
 'Remind me later'. This value specifies how long (in days) Appirater
 will wait before reminding them.
 */
#define APPIRATER_TIME_BEFORE_REMINDING		1	// double

/*
 'YES' will show the Appirater alert everytime. Useful for testing how your message
 looks and making sure the link to your app's review page works.
 */

#define APPIRATER_DEBUG				NO

#endif

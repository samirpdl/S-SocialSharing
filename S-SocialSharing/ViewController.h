//
//  ViewController.h
//  S-SocialSharing
//
//  Created by Samir Poudel on 8/13/14.
//  Copyright (c) 2014 Samir Poudel. All rights reserved.
//  samir@samirpdl.com.np
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Pinterest/Pinterest.h>
#import <Twitter/Twitter.h>
#import "TMAPIClient.h"
#import "TMTumblrAppClient.h"
#import "TMTumblrAuthenticator.h"
#import "SInstagram.h"

@interface ViewController : UIViewController <UIDocumentInteractionControllerDelegate>
{
    NSString *tumblrOAuthConsumerKey, *tumblrOAuthConsumerSecret, *tumblrOAuthToken, *tumblrOAuthTokenSecret, *tumblrBlog;
    
    NSString *pinterestAppID;
    BOOL isTumblrAuthorized;
}
@property (nonatomic, retain) UIDocumentInteractionController *docFile;



-(IBAction)fb:(id)sender;

-(IBAction)pinterest:(id)sender;

-(IBAction)tumblr:(id)sender;

-(IBAction)saveToInstagram:(id)sender;




@end

//
//  ViewController.m
//  S-SocialSharing
//
//  Created by Samir Poudel on 8/13/14.
//  Copyright (c) 2014 Samir Poudel. All rights reserved.
//  samir@samirpdl.com.np
//

#import "ViewController.h"

@interface ViewController ()
{
    Pinterest *_pinterest;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initilizetokens]; // Initalizing tokens
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTumblrNotification:)
                                                 name:@"tumblr-authorized"
                                               object:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma  mark - Initalization
-(void) initilizetokens
{
    
    /*** Pinterest  **/
    
    pinterestAppID = @""; // Your Pinterest App ID
    
    
    /** Tumblr Access Token **/
    tumblrOAuthConsumerKey = @""; // Your Tumblr OAUTH Consumer Key
    tumblrOAuthConsumerSecret = @""; // Your Tumblr OAUTH Consuer Secret Key
    
    tumblrOAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"tumblr_oauth_token"];
    tumblrOAuthTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:@"tumblr_oauth_token_secret"];
    
    tumblrBlog = [[NSUserDefaults standardUserDefaults] objectForKey:@"tumblr_blog_name"];
    
    
    if(tumblrOAuthToken ==nil || tumblrOAuthTokenSecret == nil)
    {
        isTumblrAuthorized = 0;
    }else{
        isTumblrAuthorized = 1;
    }
    
    NSLog(@"%@, %@, %@", tumblrOAuthToken, tumblrOAuthTokenSecret, tumblrBlog);
}



#pragma mark - Facebook

/**
 * A function for parsing URL parameters.
 */



- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}



-(IBAction)fb:(id)sender
{
    
    // Check if the Facebook app is installed and we can present the share dialog

    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        NSLog(@"Application is not installed so opening via browser !");
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}


#pragma mark - Pinterest


-(IBAction)pinterest:(id)sender
{
    
    _pinterest = [[Pinterest alloc] initWithClientId:pinterestAppID];
    
    if([_pinterest canPinWithSDK])
    {
        _pinterest = [[Pinterest alloc] initWithClientId:pinterestAppID];
        
        [_pinterest createPinWithImageURL:[NSURL URLWithString:@"http://samirpdl.com.np/wp-content/uploads/2014/05/Slide-1.JPG"]
                                sourceURL:[NSURL URLWithString:@"http://programminglessons.info"]
                              description:@"Pinning from S-Sharing Library"];
    }else{
        NSLog(@"No Pinterest App !");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pinterest" message:@"Would you like to download Pinterest Application to share?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        [alert show];
    }
   

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        NSString *stringURL = @"http://itunes.apple.com/us/app/pinterest/id429047995?mt=8";
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma mark - Tumblr

-(void) loadtumblrtokens
{
    [TMAPIClient sharedInstance].OAuthConsumerKey = tumblrOAuthConsumerKey;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = tumblrOAuthConsumerSecret;
    [TMAPIClient sharedInstance].OAuthToken= tumblrOAuthToken;
    [TMAPIClient sharedInstance].OAuthTokenSecret = tumblrOAuthTokenSecret;
}

-(IBAction)tumblr:(id)sender
{
   
    [self loadtumblrtokens];
    
    if(isTumblrAuthorized) // If already authorized
    {
        
        NSLog(@"Sharing with Tumblr");

       
        TMAPIClient *client = [TMAPIClient sharedInstance];
        NSDictionary *parameters = @{@"source": @"http://samirpdl.com.np/wp-content/uploads/2014/05/Slide-1.JPG", @"link": @"http://www.programminglessons.info", @"caption": @"Caption Goes here", @"tags": @"programming, test, social"};
        
        
        [client post:tumblrBlog type:@"photo" parameters:parameters
            callback:^(id response, NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                    NSLog(@"Error posting to Tumblr");
                } else {
                    NSLog(@"%@", response);
                }
            }];

   
        }else{ // if Not authorized
   
            // Getting the access tokens
            
            NSLog(@"Opening Browser for authenticating Tumblr");
            [[TMTumblrAuthenticator sharedInstance] authenticate:@"s-sharing" callback:^(NSString *token, NSString *secret, NSError *error) {
                
                NSLog(@"Authenticating with Tumblr");
            }];
    }
    

}


#pragma mark - Tumblr Notification of authorization
- (void) receiveTumblrNotification:(NSNotification *) notification
{
    if([[notification name] isEqualToString:@"tumblr-authorized"])
    {
        tumblrOAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"tumblr_oauth_token"];
        tumblrOAuthTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:@"tumblr_oauth_token_secret"];
        
        
        [self loadtumblrtokens];
        [[TMAPIClient sharedInstance] userInfo:^ (id result, NSError *error) {
            NSDictionary *response = result;
            NSDictionary *userinfo = [response objectForKey:@"user"];
            NSArray *bloginfo = [userinfo objectForKey:@"blogs"];
            NSDictionary *primaryBlog = [bloginfo objectAtIndex:0];
            NSString *blogname = [primaryBlog objectForKey:@"url"];
            blogname = [blogname stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            blogname= [blogname stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
            
            [[NSUserDefaults standardUserDefaults] setObject:blogname forKey:@"tumblr_blog_name"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            tumblrBlog = blogname;
            
            [[NSUserDefaults standardUserDefaults] setObject:blogname forKey:@"tumblr_blog_name"];
            
        }];
        
        NSLog(@"Tumblr has been authorized");
        
    }
}



#pragma mark - Instagram

- (void) postInstagramImage:(UIImage*) image
{
    NSLog(@"%@", image);
    
    if (![SInstagram isImageCorrectSize:image]) //Size Detection
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image TOO SMALL" message:@"Images must be 612x612 or larger to be posted on instagram" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
    
    if ([SInstagram isAppInstalled])
        [SInstagram postImage:image withCaption:@"This is an #SInstagram Test" inView:self.view];
    
    else
    {
        UIAlertView *noapp = [[UIAlertView alloc] initWithTitle:@"Instagram Not Installed!" message:@"Instagram must be installed on the device in order to post images" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [noapp show];
    }
}

-(IBAction)saveToInstagram:(id)sender {
    UIImage *image = [UIImage imageNamed:@"Instagram.jpg"];
    [self postInstagramImage:image];
}

@end

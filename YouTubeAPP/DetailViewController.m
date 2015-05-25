//
//  DetailViewController.m
//  YouTubeAPP
//
//  Created by Admin on 21.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "DetailViewController.h"
#import "YTPlayerView.h"
#import "YouTubeVideo.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface DetailViewController ()
@property (retain, nonatomic) NSDictionary *videoListJSON;
@property (strong, nonatomic) NSMutableArray *videoList;
@property (weak, nonatomic) IBOutlet UILabel *Published;
@property (weak, nonatomic) IBOutlet UIView *tallMpContainer;
@property (weak, nonatomic) IBOutlet UIView *mpContainer;
@property (weak, nonatomic) IBOutlet YTPlayerView *youTubePlayer;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(back)];        
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    }
   
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];    
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;    
    [self.mpContainer addGestureRecognizer:swipeDown];
    [self.mpContainer addGestureRecognizer:swipeUp];
    [self.youTubePlayer addGestureRecognizer:swipeDown];
    [self.youTubePlayer addGestureRecognizer:swipeUp];
    
}

- (BOOL)mpIsMinimized {
    return self.tallMpContainer.frame.origin.y > 0;
}

- (void)swipeDown:(UIGestureRecognizer *)gr {
    [self minimizeMp:YES animated:YES];
}

- (void)swipeUp:(UIGestureRecognizer *)gr {
    [self minimizeMp:NO animated:YES];
}

- (void)minimizeMp:(BOOL)minimized animated:(BOOL)animated 
{ 
    
    
    CGRect tallContainerFrame, containerFrame, YouTubeVideoFrame;
    CGFloat tallContainerAlpha;
    
    if (minimized)
    {
        CGFloat mpWidth = self.youTubePlayer.frame.size.width / 2;
        CGFloat mpHeight = self.youTubePlayer.frame.size.height / 2;
        CGFloat x = self.view.bounds.size.width-mpWidth - 5;
        CGFloat y = self.view.bounds.size.height-mpHeight - 1;
        tallContainerFrame = CGRectMake(x, y, 150, self.view.bounds.size.height);
        containerFrame = CGRectMake(x, y, mpWidth, mpHeight);
        YouTubeVideoFrame = CGRectMake(x, y, mpWidth, mpHeight);
        tallContainerAlpha = 0.0;
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        tallContainerFrame = CGRectMake(2, 253, 100, 500);
        containerFrame = CGRectMake(2, 53, 320, 180);
        YouTubeVideoFrame = CGRectMake(2, 70, 320, 180);
        tallContainerAlpha = 1.0;
      
    }
    
    NSTimeInterval duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        
        self.youTubePlayer.frame = YouTubeVideoFrame;
       // self.mpContainer.frame = containerFrame;
        self.tallMpContainer.frame = tallContainerFrame;
        self.tallMpContainer.alpha = tallContainerAlpha;
        
        
    }];
    if ([self mpIsMinimized] == minimized) return;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{    
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=id%%2C+snippet%%2C+contentDetails%%2C+statistics&id=%@&key=AIzaSyAUax-Gjc6Dlech0E0hXsR30WKX2i5TGtA", self.selectedVideo.videoID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         self.videoListJSON = (NSDictionary *)responseObject;
         NSDictionary *items = [responseObject objectForKey:@"items"];
         for (NSDictionary *item in items )
         {
             YouTubeVideo *youTubeVideo = [[YouTubeVideo alloc] init];
             NSDictionary* snippet = [item objectForKey:@"snippet"];
             youTubeVideo.title = [snippet objectForKey:@"title"];
             NSDictionary* statistics = [item objectForKey:@"statistics"];
             youTubeVideo.viewsCount = [statistics objectForKey:@"viewCount"];
             youTubeVideo.likesCount = [statistics objectForKey:@"likeCount"];
             youTubeVideo.dislikesCount = [statistics objectForKey:@"dislikeCount"];
             [self.videoList addObject:youTubeVideo];
             NSDictionary *playerVars = @{@"playsinline" : @1,
                                          @"modestbranding": @1,
                                          @"showinfo": @0,
                                          @"controls": @2,
                                          @"iv_load_policy": @3,
                                          @"rel": @0,
                                          @"theme": @"light",
                                          @"fs":@1,
                                          @"autohide":@0
                                          };
             [self.youTubePlayer loadWithVideoId:self.selectedVideo.videoID playerVars:playerVars];
             [self.youTubePlayer playVideo];
             [self.PublishedAt setText:self.selectedVideo.published];
             [self.Title setText:self.selectedVideo.title];
             [self.view_counts setText:youTubeVideo.viewsCount];
             [self.like setText:youTubeVideo.likesCount];
             [self.dislike setText:youTubeVideo.dislikesCount];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connection"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
     }];
    [super viewWillAppear:animated];
    [operation start];
    [UIView animateWithDuration:0.3 animations:^
     {
         CGRect playerViewRect = self.youTubePlayer.frame;
       //  CGRect detailsViewRect = self.detailsView.frame;
         
         playerViewRect.origin.x = 0;
         playerViewRect.origin.y = 0;
         playerViewRect.size.width = self.view.bounds.size.width;
         playerViewRect.size.height = playerViewRect.size.width / 16 * 9 + 20;
         self.youTubePlayer.frame = playerViewRect;
         //[self.playerView setSizeOfIFrameToWidth:160 Height:90];
     }];
}

- (IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>

static bool waiting = true;
static bool addedJsLoadErrorObserver = false;
static UIViewController *splashViewController = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(SplashScreen)

RCT_EXPORT_METHOD(hide) {
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    [RNSplashScreen show];
}

+ (void)initialize {
    if (!addedJsLoadErrorObserver) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsLoadError:)
                                                     name:RCTJavaScriptDidFailToLoadNotification
                                                   object:nil];
        addedJsLoadErrorObserver = true;
    }
}

+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!splashViewController) {
            RCTLogInfo(@"Loading LaunchScreen storyboard...");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
            splashViewController = [storyboard instantiateInitialViewController];

            if (!splashViewController) {
                RCTLogError(@"Failed to load LaunchScreen storyboard");
                return;
            }

            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            splashViewController.view.frame = [UIScreen mainScreen].bounds;
            [window addSubview:splashViewController.view];
        }
    });
}

+ (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (splashViewController) {
            [UIView transitionWithView:splashViewController.view
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                splashViewController.view.alpha = 0.5;
            } completion:^(BOOL finished) {
                [splashViewController.view removeFromSuperview];
                splashViewController = nil;
            }];
        }
    });
}

+ (void) jsLoadError:(NSNotification*)notification
{
    // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise the splash screen will remain forever, which is a hassle to debug.
    [RNSplashScreen hide];
}

@end


## Cordova Plugin that wraps Mixpanel SDK for Android and iOS

- [android sdk version 4.6.2]
- [ios sdk version 2.8.2]

#### Install

```
cordova plugin add https://github.com/mib200/mixpanel-cordova.git
```

For Android, AndroidManifest.xml is automatically updated to work with MixPanel push.

For IOS, please add following code in AppDelegate.m

```
#import "MixpanelPlugin.h"

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    MixpanelPlugin *mixpanelHandler = [self getCommandInstance:@"Mixpanel"];
    [mixpanelHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Show alert for push notifications recevied while the
    // app is running
    [[Mixpanel sharedInstance] trackPushNotification:userInfo];
    
    NSString *message = [[userInfo objectForKey:@"aps"]
                         objectForKey:@"alert"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}
```

##### Keywords
mixpanel, plugin cordova, phonegap, ionic, android, ios
#import "MixpanelPlugin.h"

@implementation MixpanelPlugin


// MIXPANEL API


-(void)alias:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    NSArray* arguments = command.arguments;
    NSString* aliasId = [arguments objectAtIndex:0];
    NSString* originalId = [arguments objectAtIndex:1];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else if(aliasId == nil || 0 == [aliasId length])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Alias id missing"];
    }
    else
    {
        [mixpanelInstance createAlias:aliasId forDistinctID:originalId];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
{
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    [mixpanelInstance.people addPushDeviceToken:deviceToken];

    // Call .identify to flush the People record to Mixpanel
    [mixpanelInstance identify:mixpanelInstance.distinctId];
}

-(void)flush:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else
    {
        [mixpanelInstance flush];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)identify:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    NSArray* arguments = command.arguments;
    NSString* distinctId = [arguments objectAtIndex:0];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else
    {
        if(distinctId == nil || 0 == [distinctId length])
        {
            distinctId = mixpanelInstance.distinctId;
        }
        [mixpanelInstance identify:distinctId];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)init:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    NSArray* arguments = command.arguments;
    NSString* token = [arguments objectAtIndex:0];

    if (token == nil || 0 == [token length])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Token is missing"];
    }
    else
    {
        [Mixpanel sharedInstanceWithToken:token];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)reset:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else
    {
        [mixpanelInstance reset];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)track:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    NSArray* arguments = command.arguments;
    NSString* eventName = [arguments objectAtIndex:0];
    NSDictionary* eventProperties = [command.arguments objectAtIndex:1];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else if(eventName == nil || 0 == [eventName length])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Event name missing"];
    }
    else
    {
        [mixpanelInstance track:eventName properties:eventProperties];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)register_super_properties:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    NSArray* arguments = command.arguments;
    NSDictionary* properties = [command.arguments objectAtIndex:0];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else if(properties == nil || 0 == [properties count])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"missing properties object"];
    }
    else
    {
        [mixpanelInstance registerSuperProperties:properties];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


// PEOPLE API


-(void)people_identify:(CDVInvokedUrlCommand*)command;
{
    // ios sdk doesnt have separate people identify method
    // just call the normal identify call
    [self identify:command];
}


-(void)people_init_push_handling:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    
    // Tell iOS you want your app to receive push notifications
    // This code will work in iOS 8.0 xcode 6.0 or later:
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    // This code will work in iOS 7.0 and below:
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)people_set:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;
    Mixpanel* mixpanelInstance = [Mixpanel sharedInstance];
    NSArray* arguments = command.arguments;
    NSDictionary* peopleProperties = [command.arguments objectAtIndex:0];

    if (mixpanelInstance == nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Mixpanel not initialized"];
    }
    else if(peopleProperties == nil || 0 == [peopleProperties count])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"missing people properties object"];
    }
    else
    {
        [mixpanelInstance.people set:peopleProperties];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end

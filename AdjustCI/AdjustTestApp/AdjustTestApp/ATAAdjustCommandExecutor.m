//
//  ATAAdjustCommandExecutor.m
//  AdjustTestApp
//
//  Created by Pedro on 23.08.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ATAAdjustCommandExecutor.h"
#import "Adjust.h"
#import "ADJAdjustFactory.h"

@interface ATAAdjustCommandExecutor ()

@property (nonatomic, strong) NSMutableDictionary *savedConfigs;
@property (nonatomic, strong) NSMutableDictionary *savedEvents;
@property (nonatomic, copy) NSString *basePath;

@end

@implementation ATAAdjustCommandExecutor

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.savedConfigs = [NSMutableDictionary dictionary];
    self.savedEvents = [NSMutableDictionary dictionary];

    return self;
}

- (void)executeCommand:(NSString *)className
            methodName:(NSString *)methodName
            parameters:(NSDictionary *)parameters {

    NSLog(@"executeCommand className: %@, methodName: %@, parameters: %@", className, methodName, parameters);

    if ([methodName isEqualToString:@"factory"]) {

    } else if ([methodName isEqualToString:@"config"]) {
        [self config:parameters];
    } else if ([methodName isEqualToString:@"start"]) {
        [self start:parameters];
    } else if ([methodName isEqualToString:@"event"]) {
        [self event:parameters];
    } else if ([methodName isEqualToString:@"trackEvent"]) {
        [self trackEvent:parameters];
    } else if ([methodName isEqualToString:@"resume"]) {
        [self resume:parameters];
    } else if ([methodName isEqualToString:@"pause"]) {
        [self pause:parameters];
    } else if ([methodName isEqualToString:@"setEnabled"]) {
        [self setEnabled:parameters];
    } else if ([methodName isEqualToString:@"setReferrer"]) {
        [self setReferrer:parameters];
    } else if ([methodName isEqualToString:@"setOfflineMode"]) {
        [self setOfflineMode:parameters];
    } else if ([methodName isEqualToString:@"sendFirstPackages"]) {
        [self sendFirstPackages:parameters];
    } else if ([methodName isEqualToString:@"addSessionCallbackParameter"]) {
        [self addSessionCallbackParameter:parameters];
    } else if ([methodName isEqualToString:@"addSessionPartnerParameter"]) {
        [self addSessionPartnerParameter:parameters];
    } else if ([methodName isEqualToString:@"removeSessionCallbackParameter"]) {
        [self removeSessionCallbackParameter:parameters];
    } else if ([methodName isEqualToString:@"removeSessionPartnerParameter"]) {
        [self removeSessionPartnerParameter:parameters];
    } else if ([methodName isEqualToString:@"resetSessionCallbackParameters"]) {
        [self resetSessionCallbackParameters:parameters];
    } else if ([methodName isEqualToString:@"resetSessionPartnerParameters"]) {
        [self resetSessionPartnerParameters:parameters];
    } else if ([methodName isEqualToString:@"setPushToken"]) {
        [self setPushToken:parameters];
    } else if ([methodName isEqualToString:@"teardown"]) {
        [self teardown:parameters];
    } else if ([methodName isEqualToString:@"openDeeplink"]) {
        [self openDeeplink:parameters];
    } else if ([methodName isEqualToString:@"sendReferrer"]) {
        [self sendReferrer:parameters];
    } else if ([methodName isEqualToString:@"testBegin"]) {
        [self testBegin:parameters];
    } else if ([methodName isEqualToString:@"testEnd"]) {
        [self testEnd:parameters];
    }
}

- (void)config:(NSDictionary *)parameters {
    NSNumber * configNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"configName"]) {
        NSString * configName = [parameters objectForKey:@"configName"][0];
        NSString *configNumberS = [configName substringFromIndex:[configName length] - 1];
        configNumber = [NSNumber numberWithInt:[configNumberS intValue]];
    }

    ADJConfig * adjustConfig = nil;

    if ([self.savedConfigs objectForKey:configNumber]) {
        adjustConfig = [self.savedConfigs objectForKey:configNumber];
    } else {
        NSString * environment = [parameters objectForKey:@"environment"][0];
        NSString * appToken = [parameters objectForKey:@"appToken"][0];

        adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
        [self.savedConfigs setObject:adjustConfig forKey:configNumber];
    }

    if ([parameters objectForKey:@"logLevel"]) {
        NSString * logLevelS = [parameters objectForKey:@"logLevel"][0];
        ADJLogLevel logLevel = [ADJLogger logLevelFromString:logLevelS];
        [adjustConfig setLogLevel:logLevel];
    }
/*
    NSLog(@"parameters: %@", parameters);
    for (NSString *key in parameters) {
        NSLog(@"key: %@", key);
        NSArray * values = [parameters objectForKey:key];
        NSLog(@"values: %@", values);
    }
 */
}

- (void)start:(NSDictionary *)parameters {
    [self config:parameters];

    NSNumber * configNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"configName"]) {
        NSString * configName = [parameters objectForKey:@"configName"][0];
        NSString *configNumberS = [configName substringFromIndex:[configName length] - 1];
        configNumber = [NSNumber numberWithInt:[configNumberS intValue]];
    }

    ADJConfig * adjustConfig = [self.savedConfigs objectForKey:configNumber];

    [adjustConfig setBasePath:self.basePath];

    [Adjust appDidLaunch:adjustConfig];

    [self.savedConfigs removeObjectForKey:[NSNumber numberWithInt:0]];
}

- (void)event:(NSDictionary *)parameters {

}

- (void)trackEvent:(NSDictionary *)parameters {

}

- (void)resume:(NSDictionary *)parameters {
    [Adjust trackSubsessionStart];
}

- (void)pause:(NSDictionary *)parameters {
    [Adjust trackSubsessionEnd];
}

- (void)setEnabled:(NSDictionary *)parameters {

}

- (void)setReferrer:(NSDictionary *)parameters {

}

- (void)setOfflineMode:(NSDictionary *)parameters {

}

- (void)sendFirstPackages:(NSDictionary *)parameters {

}

- (void)addSessionCallbackParameter:(NSDictionary *)parameters {

}

- (void)addSessionPartnerParameter:(NSDictionary *)parameters {

}

- (void)removeSessionCallbackParameter:(NSDictionary *)parameters {

}

- (void)removeSessionPartnerParameter:(NSDictionary *)parameters {

}

- (void)resetSessionCallbackParameters:(NSDictionary *)parameters {

}

- (void)resetSessionPartnerParameters:(NSDictionary *)parameters {

}

- (void)setPushToken:(NSDictionary *)parameters {

}

- (void)teardown:(NSDictionary *)parameters {

}

- (void)openDeeplink:(NSDictionary *)parameters {

}

- (void)sendReferrer:(NSDictionary *)parameters {

}

- (void)testBegin:(NSDictionary *)parameters {
    NSLog(@"testBegin parameters: %@", parameters);

    if ([parameters objectForKey:@"basePath"]) {
        self.basePath = [parameters objectForKey:@"basePath"][0];
    }

    [ADJAdjustFactory teardown:YES];
    self.savedConfigs = [NSMutableDictionary dictionary];
    self.savedEvents = [NSMutableDictionary dictionary];
}

- (void)testEnd:(NSDictionary *)parameters {
    [ADJAdjustFactory teardown:YES];
}
@end

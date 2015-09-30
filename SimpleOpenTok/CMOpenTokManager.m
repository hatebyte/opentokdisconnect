//
//  CMOpenTokManager.m
//  CaptureMedia-Data
//
//  Created by hatebyte on 11/4/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMOpenTokManager.h"
#import "MyOTGLKVideoView.h"

static NSString* const kApiKey              = @"44930302";
@interface CMOpenTokManager ()

@property(nonatomic, strong, readwrite) OTSession *session;
@property(nonatomic, strong, readwrite) OTPublisher *publisher;
@property(nonatomic, strong, readwrite) OTSubscriber *subscriber;
@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, strong) NSString *token;
@property(nonatomic, strong) dispatch_queue_t otMangerQueue;

@end

/*
 openTok tokens
 
 APIKEY         = 45358832
 secret 		= cf310c4b2595d5d9cae0c57f3d0f69d0360eb920
 session id 	= 2_MX40NTM1ODgzMn5-MTQ0MzU2MTU5MzM0Mn4wNi92dzM4eDdkZjAyYXdiUXJYTTVrWGJ-UH4
 token          = T1==cGFydG5lcl9pZD00NTM1ODgzMiZzaWc9YmQ2NWM4NDc5NTFjNGRmZjJhNTQ0NWRjMzFjNmQzODhkNzkyOTVlMzpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTJfTVg0ME5UTTFPRGd6TW41LU1UUTBNelUyTVRVNU16TTBNbjR3Tmk5MmR6TTRlRGRrWmpBeVlYZGlVWEpZVFRWcldHSi1VSDQmY3JlYXRlX3RpbWU9MTQ0MzU2MzExNSZub25jZT0wLjE1OTM2NzU3NDc4MTQ1NzkmZXhwaXJlX3RpbWU9MTQ0NjE1MzU4OSZjb25uZWN0aW9uX2RhdGE9
 
 */

@implementation CMOpenTokManager

+ (instancetype)openTokWithSession {
    return [[self.class alloc] initWithSessionId:@"2_MX40NTM1ODgzMn5-MTQ0MzU2MTU5MzM0Mn4wNi92dzM4eDdkZjAyYXdiUXJYTTVrWGJ-UH4" token:@"T1==cGFydG5lcl9pZD00NTM1ODgzMiZzaWc9YmQ2NWM4NDc5NTFjNGRmZjJhNTQ0NWRjMzFjNmQzODhkNzkyOTVlMzpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTJfTVg0ME5UTTFPRGd6TW41LU1UUTBNelUyTVRVNU16TTBNbjR3Tmk5MmR6TTRlRGRrWmpBeVlYZGlVWEpZVFRWcldHSi1VSDQmY3JlYXRlX3RpbWU9MTQ0MzU2MzExNSZub25jZT0wLjE1OTM2NzU3NDc4MTQ1NzkmZXhwaXJlX3RpbWU9MTQ0NjE1MzU4OSZjb25uZWN0aW9uX2RhdGE9"];
}

- (instancetype)initWithSessionId:(NSString *)sessionId token:(NSString *)token {
    self = [super init];
    if (self) {
        self.token                              = token;
        self.session                            = [self getSessionWithToken:sessionId];
        self.publisher                          = [self getPublisher];
        self.publisher.publishVideo             = NO;
    }
    return self;
}

- (void)connect {
    OTError *error                              = nil;
    [self.session connectWithToken:self.token error:&error];
    if (error) {
        [self informDelegateOfErrorInfo:error.userInfo];
        return;
    }
}

- (void)disconnect {
    if (self.session && _session.sessionConnectionStatus == OTSessionConnectionStatusConnected) {
        NSLog(@"OpenTok disconnecting....");
        [self.session unpublish:self.publisher error:nil];
        [self.session unsubscribe:self.subscriber error:nil];
        [self.session disconnect:nil];
    }
}


#pragma mark - gcd threading
- (void)toMainQueue:(void(^)())block {
#if TEST==1
    block();
#else
    dispatch_async(dispatch_get_main_queue(), block);
#endif
}

#pragma mark - private
- (void)addPublisher {
    OTError *error;
    [self.session publish:self.publisher error:&error];
    if (error) {
        [self informDelegateOfErrorInfo:error.userInfo];
    }
}

- (void)addSubscriber {
    OTError *error = nil;
    [self.session subscribe:self.subscriber error:&error];
    if (error) {
        [self informDelegateOfErrorInfo:error.userInfo];
    }
}

- (void)informDelegateOfErrorInfo:(NSDictionary *)errorDict {
    __weak typeof(self) weakSelf            = self;
    NSError *e                              = [NSError errorWithDomain:CMOpenTokErrorDomain code:CMOpenTokErrorCodeConnectionFailed userInfo:errorDict];
    [self toMainQueue:^{
        [weakSelf.delegate openTokDisconnectedWithError:e];
    }];
}

- (void)cleanUp {
//    [OTAudioDeviceManager setAudioDevice:nil];
//    self.session.delegate                   = nil;
//    self.publisher.delegate                 = nil;
//    self.session                            = nil;
//    self.publisher                          = nil;
}


#pragma mark - opentok properties
- (OTSession *)getSessionWithToken:(NSString *)sessionId {
    return [[OTSession alloc] initWithApiKey:@"45358832" sessionId:@"2_MX40NTM1ODgzMn5-MTQ0MzU2MTU5MzM0Mn4wNi92dzM4eDdkZjAyYXdiUXJYTTVrWGJ-UH4" delegate:self];
}

- (OTPublisher *)getPublisher {
    OTPublisher *p = [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
    MyOTGLKVideoView *view = [[MyOTGLKVideoView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_publisher setValue:view forKey:@"_videoView"];
    [_publisher setVideoRender:(id)view];
    return p;
//    return [[OTPublisher alloc] initWithDelegate:self name:[[UIDevice currentDevice] name]];
}

- (OTSubscriber *)getSubscriberWithStream:(OTStream *)stream {
    OTSubscriber *x = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    MyOTGLKVideoView *view = [[MyOTGLKVideoView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_subscriber setValue:view forKey:@"_videoView"];
    [_subscriber setVideoRender:(id)view];
    return x;
//    return [[OTSubscriber alloc] initWithStream:stream delegate:self];
}




#pragma mark - session delegate
//SECOND
- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection {
    NSLog(@"addConnection: %@", connection.connectionId);
}

- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection {
    NSLog(@"connectionDestroyed: %@", connection);
    [self cleanUp];
    __weak typeof(self) weakSelf                = self;
    [weakSelf informDelegateOfErrorInfo:@{
                                          NSLocalizedDescriptionKey : NSLocalizedString(@"OpenTok connection was destroyed", @"OpenTok Error : connectionDestroyed")
                                          }];
}

// FIRST
- (void)sessionDidConnect:(OTSession *)session {
    [self addPublisher];
}

// Sent when the phone disconnects from the session.
- (void)sessionDidDisconnect:(OTSession *)session {
    [self cleanUp];
    [self toMainQueue:^{
        [self.delegate openTokDidDisconnect];
    }];
}

//THIRD
- (void)session:(OTSession*)session streamCreated:(OTStream *)stream {
    self.subscriber                                 = [self getSubscriberWithStream:stream];
    self.subscriber.subscribeToVideo                = NO;
    
    [self addSubscriber];
}

// Sent when the website disconnects from the session.
- (void)session:(OTSession*)session streamDestroyed:(OTStream*)stream {
    [self cleanUp];
    [self informDelegateOfErrorInfo:@{
                                      NSLocalizedDescriptionKey : NSLocalizedString(@"Open stream was destroyed", @"OpenTok Error : streamDestroyed")
                                      }];
}

// Sent if the session fails to connect, some time after your application
- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    [self informDelegateOfErrorInfo:error.userInfo];
}



#pragma mark - subscriber delegate
// FORTH (PROBLY)
- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber {
    __weak typeof(self) weakSelf                = self;
    [self toMainQueue:^{
        [weakSelf.delegate openTokHasConnected];
    }];
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error {
    [self informDelegateOfErrorInfo:error.userInfo];
}


#pragma mark - publisher delegate
// FIFTH (PROBLY)
- (void)publisher:(OTPublisherKit *)publisher streamCreated:(OTStream *)stream {
    
}

- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error {
    [self informDelegateOfErrorInfo:error.userInfo];
}

@end

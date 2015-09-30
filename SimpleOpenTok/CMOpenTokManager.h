//
//  CMOpenTokManager.h
//  CaptureMedia-Data
//
//  Created by hatebyte on 11/4/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

@protocol CMOpenTokManagerDelegate <NSObject>

- (void)openTokHasConnected;
- (void)openTokDisconnectedWithError:(NSError *)error;
- (void)openTokDidDisconnect;

@end

typedef enum {
    CMOpenTokErrorCodeConnectionFailed,
    CMOpenTokErrorCodeDisconnected
}
CMOpenTokErrorCode;

static NSString *CMOpenTokErrorDomain = @"com.capturemedia.opentok.error";

@class OTSession, OTPublisher, OTSubscriber;
@interface CMOpenTokManager : NSObject <OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

@property(nonatomic, strong, readonly) OTSession *session;
@property(nonatomic, strong, readonly) OTPublisher *publisher;
@property(nonatomic, strong, readonly) OTSubscriber *subscriber;
@property(nonatomic, weak) id <CMOpenTokManagerDelegate> delegate;

+ (instancetype)openTokWithSession;

- (void)connect;
- (void)disconnect;

@end

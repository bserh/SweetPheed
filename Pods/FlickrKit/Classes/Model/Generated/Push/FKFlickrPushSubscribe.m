//
//  FKFlickrPushSubscribe.m
//  FlickrKit
//
//  Generated by FKAPIBuilder.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrPushSubscribe.h" 

@implementation FKFlickrPushSubscribe



- (BOOL) needsLogin {
    return YES;
}

- (BOOL) needsSigning {
    return YES;
}

- (FKPermission) requiredPerms {
    return 0;
}

- (NSString *) name {
    return @"flickr.push.subscribe";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];
	if(!self.topic) {
		valid = NO;
		[errorDescription appendString:@"'topic', "];
	}
	if(!self.callback) {
		valid = NO;
		[errorDescription appendString:@"'callback', "];
	}
	if(!self.verify) {
		valid = NO;
		[errorDescription appendString:@"'verify', "];
	}

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.topic) {
		[args setValue:self.topic forKey:@"topic"];
	}
	if(self.callback) {
		[args setValue:self.callback forKey:@"callback"];
	}
	if(self.verify) {
		[args setValue:self.verify forKey:@"verify"];
	}
	if(self.verify_token) {
		[args setValue:self.verify_token forKey:@"verify_token"];
	}
	if(self.lease_seconds) {
		[args setValue:self.lease_seconds forKey:@"lease_seconds"];
	}
	if(self.woe_ids) {
		[args setValue:self.woe_ids forKey:@"woe_ids"];
	}
	if(self.place_ids) {
		[args setValue:self.place_ids forKey:@"place_ids"];
	}
	if(self.lat) {
		[args setValue:self.lat forKey:@"lat"];
	}
	if(self.lon) {
		[args setValue:self.lon forKey:@"lon"];
	}
	if(self.radius) {
		[args setValue:self.radius forKey:@"radius"];
	}
	if(self.radius_units) {
		[args setValue:self.radius_units forKey:@"radius_units"];
	}
	if(self.accuracy) {
		[args setValue:self.accuracy forKey:@"accuracy"];
	}
	if(self.nsids) {
		[args setValue:self.nsids forKey:@"nsids"];
	}
	if(self.tags) {
		[args setValue:self.tags forKey:@"tags"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrPushSubscribeError_RequiredParameterMissing:
			return @"Required parameter missing";
		case FKFlickrPushSubscribeError_InvalidParameterValue:
			return @"Invalid parameter value";
		case FKFlickrPushSubscribeError_CallbackURLAlreadyInUseForADifferentSubscription:
			return @"Callback URL already in use for a different subscription";
		case FKFlickrPushSubscribeError_CallbackFailedOrInvalidResponse:
			return @"Callback failed or invalid response";
		case FKFlickrPushSubscribeError_ServiceCurrentlyAvailableOnlyToProAccounts:
			return @"Service currently available only to pro accounts";
		case FKFlickrPushSubscribeError_SubscriptionAwaitingVerificationCallbackResponseTryAgainLater:
			return @"Subscription awaiting verification callback response - try again later";
		case FKFlickrPushSubscribeError_SSLIsRequired:
			return @"SSL is required";
		case FKFlickrPushSubscribeError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrPushSubscribeError_MissingSignature:
			return @"Missing signature";
		case FKFlickrPushSubscribeError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrPushSubscribeError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrPushSubscribeError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrPushSubscribeError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrPushSubscribeError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrPushSubscribeError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrPushSubscribeError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrPushSubscribeError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrPushSubscribeError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrPushSubscribeError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end

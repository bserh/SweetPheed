//
//  FKFlickrBlogsGetList.m
//  FlickrKit
//
//  Generated by FKAPIBuilder.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrBlogsGetList.h" 

@implementation FKFlickrBlogsGetList



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
    return @"flickr.blogs.getList";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];

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
	if(self.service) {
		[args setValue:self.service forKey:@"service"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrBlogsGetListError_SSLIsRequired:
			return @"SSL is required";
		case FKFlickrBlogsGetListError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrBlogsGetListError_MissingSignature:
			return @"Missing signature";
		case FKFlickrBlogsGetListError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrBlogsGetListError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrBlogsGetListError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrBlogsGetListError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrBlogsGetListError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrBlogsGetListError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrBlogsGetListError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrBlogsGetListError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrBlogsGetListError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrBlogsGetListError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
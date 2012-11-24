//
//  Cacheing_Tests.m
//  Cacheing Tests
//
//  Created by Daniel Demiss on 22.11.12.
//  Copyright (c) 2012 Daniel Demiss. All rights reserved.
//

#import "Cacheing_Tests.h"

@implementation Cacheing_Tests

+ (NSBundle *)testsBundle
{
	return [NSBundle bundleForClass:self];
}

+ (NSString *)imageName
{
	NSString *imageName = @"Font Book";
	NSString *extension = @"tiff";
	NSAssert2([[self testsBundle] URLForResource:imageName withExtension:extension], @"There’s no image named “%@.%@” in the tests bundle!", imageName, extension);

	return [imageName stringByAppendingPathExtension:extension];
}

- (void)testImageLookup
{
	NSBundle *testBundle = [Cacheing_Tests testsBundle];
	NSString *imageName = [Cacheing_Tests imageName];
	@autoreleasepool {
		UIImage *retrievedImage = [UIImage d12_imageNamed:imageName inBundle:testBundle];
		STAssertNotNil(retrievedImage, @"Failed to lookup image for name “%@”", imageName);
	}
}

- (void)testCacheHits
{
	@autoreleasepool {
		UIImage *imageFromDisk = [UIImage d12_imageNamed:[Cacheing_Tests imageName] inBundle:[Cacheing_Tests testsBundle]];
		UIImage *cachedImage = [UIImage d12_imageNamed:[Cacheing_Tests imageName] inBundle:[Cacheing_Tests testsBundle]];
		STAssertTrue(cachedImage == imageFromDisk, @"Cache lookup failed although the cache should have been hit!");
	}
}

- (void)testKeepAlive
{
	UIImage *persistentlyCachedInstance;
	@autoreleasepool {
		persistentlyCachedInstance = [[UIImage d12_imageNamed:[Cacheing_Tests imageName] inBundle:[Cacheing_Tests testsBundle]] retain];
	}
}

@end

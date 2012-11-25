/*
 UIImage+D12_SecondaryBundleCacheSupport.m
 CachedImage

 Created by Daniel Demiss on 22.11.12.
 Copyright (c) 2012, Dock12
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 o Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 o Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "UIImage+D12_SecondaryBundleCacheSupport.h"

static BOOL s_shouldPreferRetinaGraphics;
static NSString *s_bundleDidUnloadNotificationName = @"D12: Bundle Did Unload!";
static NSMutableDictionary *s_cachesByBundleIdentifier;
static dispatch_queue_t s_imageCacheMutationQueue;
static inline NSURL *sResolvedURLForImageNameInBundle(NSString *name, NSBundle *bundle, BOOL *isRetinaImage)
{
	NSString *extension = [name pathExtension];
	if (!extension)
		extension = @"png";
	
	NSString *basename = [name stringByDeletingPathExtension];
	NSURL *imageURL = nil;
	if (s_shouldPreferRetinaGraphics)
		imageURL = [bundle URLForResource:[basename stringByAppendingString:@"@2x"]  withExtension:extension];

	if (imageURL) {
		if (isRetinaImage)
			*isRetinaImage = YES;
	} else {
		imageURL = [bundle URLForResource:basename withExtension:extension];
		if (isRetinaImage)
			*isRetinaImage = NO;
	}

	return imageURL;
}

@implementation UIImage (D12_SecondaryBundleCacheSupport)

#import <objc/runtime.h>
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		@autoreleasepool {
			// Because we want to evict all cache entries for a bundle when it’s unloaded, we are going to create seperate caches for each bundle.
			s_cachesByBundleIdentifier = [NSMutableDictionary new];
			// We’ll coordinate accesses to our globally shared mutable resource through a serial queue.
			s_imageCacheMutationQueue = dispatch_queue_create("net.dock12.secondary-bundle-image-cache.mutation-queue", DISPATCH_QUEUE_SERIAL);

			// Cache-misses are expensive already, so we only determine whether we should prefer using retina resources once:
			s_shouldPreferRetinaGraphics = ([[UIScreen mainScreen] scale] > 1.0);

			// NSBundle posts a notification when a bundle is loaded, but not on unload.
			// This stinks, because an unloaded bundle means we can purge the cache  associated with it.
			// Therefore, we’ll instrument -[NSBundle unload] such, that it posts a notification if it unloads its contents, and then observe that.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUnloadNotification:) name:s_bundleDidUnloadNotificationName object:nil];
			SEL unload = @selector(unload);
			Class bundle = [NSBundle class];
			IMP originalUnload = class_getMethodImplementation(bundle, unload);
			assert(originalUnload);
			// Most interestingly, block-based implementations omit the _cmd argument that usually follows `self`.
			IMP replacementForUnload = imp_implementationWithBlock(^(id self){
				BOOL didUnload = ((BOOL(*)(id, SEL))originalUnload)(self, unload);
				if (didUnload)
					[[NSNotificationCenter defaultCenter] postNotificationName:s_bundleDidUnloadNotificationName object:self];

				return didUnload;
			});
			class_replaceMethod([NSBundle class], unload, replacementForUnload, "c@:");
		}
	});
}

+ (UIImage *)d12_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle
{
	BOOL canResortToStandardMechanism = (!bundle
										 || [bundle isEqual:[NSBundle mainBundle]]);
	if (canResortToStandardMechanism)
		return [UIImage imageNamed:name];

	// NSCache doesn’t like `nil` keys, so we’ll just exit in that case…
	if (!name)
		return nil;

	__block UIImage *image = nil;
	NSString *bundleID = [bundle bundleIdentifier];
	dispatch_sync(s_imageCacheMutationQueue, ^{
		NSCache *bundleCache = [s_cachesByBundleIdentifier objectForKey:bundleID];
		if (!bundleCache) {
			bundleCache = [NSCache new];
			[s_cachesByBundleIdentifier setObject:bundleCache forKey:bundleID];
		}
		if ((image = [bundleCache objectForKey:name]))
			return; // Cache hit -> Done!

		BOOL isRetinaImage;
		NSURL *imageURL = sResolvedURLForImageNameInBundle(name, bundle, &isRetinaImage);
		if (!imageURL)
			return; // No such resource -> Done!

		if ((image = [[UIImage alloc] initWithContentsOfFile:[imageURL path]]))
			[bundleCache setObject:image forKey:name]; // Resource found -> Store it in the cache!
	});

	return image;
}

+ (void)didReceiveUnloadNotification:(NSNotification *)notification
{
	NSString *bundleID = [[notification object] bundleIdentifier];
	dispatch_async(s_imageCacheMutationQueue, ^{
		@autoreleasepool {
			[s_cachesByBundleIdentifier removeObjectForKey:bundleID];
		}
	});
}

@end

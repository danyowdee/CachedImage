/*
 UIImage+D12_SecondaryBundleCacheSupport.h
 CachedImage

 Created by Daniel Demiss on 22.11.12.
 Copyright (c) 2012, Dock12
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 o Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 o Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIImage.h>

@interface UIImage (D12_SecondaryBundleCacheSupport)

/**
 Returns the image object associated with the specified filename from the specified bundle.

 This method looks in the system caches for an image object with the specified name and returns that object if it exists.
 If a matching image object is not already in the cache, this method loads the image data from the specified file, caches it, and then returns the resulting object.

 Like “The Real Deal™”, this method attempts loading @2x versions on retina devices.
 In fact, if bundle is `nil`, or the main bundle, this method uses the standard `+[UIImage imageNamed:]`.

 @param  name    The name of the file.
 If this is the first time the image is being loaded, the method looks for an image with the specified name in the application’s main bundle.
 @param  bundle  The bundle from which to load the image.

 @return The image object for the specified file from the specified bundle, or `nil` if the method could not find the specified image.
 */
+ (UIImage *)d12_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

@end

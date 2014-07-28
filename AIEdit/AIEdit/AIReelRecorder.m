//
//  AIReelRecorder.m
//  AIEdit
//
//  Created by Akasaka Ryuunosuke on 24/07/14.
//  Copyright (c) 2014 Akasaka Ryuunosuke. All rights reserved.
//
#import "zlib.h"
#import "AIReelRecorder.h"
#import "AITapeTrack.h"
@implementation AIReelRecorder
+ (AIReelRecorder *)sharedInstance
{
    static AIReelRecorder *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}
- (NSData *)gzipInflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

- (NSData *)gzipDeflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = [data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_BEST_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}
- (NSDictionary*) openReelFromFile:(NSURL*)file extractedTo:(NSURL*)folder{
    NSDictionary* reel = [NSDictionary dictionaryWithContentsOfURL:file];
    NSArray* files = reel[@"files"];
    // unzip all files
    for (NSDictionary*file in files) {
        NSString* fname = file[@"name"];
        NSData* content = file[@"content"];
        NSError*e = nil;
        [[self gzipInflate:content] writeToURL:[folder URLByAppendingPathComponent:fname] options:NSDataWritingWithoutOverwriting error:&e];
        if (e) {
            NSAlert* msgBox = [[NSAlert alloc] init] ;
            [msgBox setMessageText: [NSString stringWithFormat:@"Error extracting %@", fname]];
            [msgBox setInformativeText:e.localizedDescription];
            [msgBox addButtonWithTitle: @"OK"];
            [msgBox runModal];
        }
    }
    // fixup proj paths
    NSMutableDictionary *project = [reel[@"project"] mutableCopy];
    NSMutableArray* projContent = [[NSKeyedUnarchiver unarchiveObjectWithData:project[@"data"]]mutableCopy];
    for (NSInteger i=0; i < projContent.count; i++) {
        AITapeTrack* t = [projContent objectAtIndex:i];
        if (![@"Gap" isEqualToString:t.fname]) {
            t.url = [folder URLByAppendingPathComponent:t.fname];
        }
        [projContent setObject:t atIndexedSubscript:i];
    }
    [project setObject:[NSKeyedArchiver archivedDataWithRootObject:projContent] forKey:@"data"];
    [project writeToURL:[folder URLByAppendingPathComponent:@"_project.tape"] atomically:false];
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:file.path
                                            destination:@""
                                                  files:[NSArray arrayWithObject:file.path]
                                                    tag:nil];
    [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"tapedoc"] forFile:[folder URLByAppendingPathComponent:@"_project.tape"].path options:0];
    return project;
}
- (void) createReel:(NSURL*)dest fromTracks:(NSArray*)tracks pData:(NSDictionary*)project {
    NSMutableDictionary* reel = [NSMutableDictionary new];
    NSMutableDictionary*p = [project mutableCopy];
    [p setObject:[NSKeyedArchiver archivedDataWithRootObject:tracks] forKey:@"data"];
    [reel setObject:p forKey:@"project"];
    NSMutableArray* files= [NSMutableArray new];
    for (AITapeTrack*t in tracks) {
        if(![@"Gap" isEqualToString:t.fname])
            [files addObject:@{@"name":t.fname, @"content":[self gzipDeflate:[NSData dataWithContentsOfURL:t.url]]}];
    }
    [reel setObject:files forKey:@"files"];
    [reel writeToURL:dest atomically:false];
    [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"tapemas"] forFile:dest.path options:0];
}
@end

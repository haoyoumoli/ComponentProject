//
//  TGAHeader.h
//  FIleDemo
//
//  Created by apple on 2021/10/27.
//

#ifndef TGAHeader_h
#define TGAHeader_h


typedef struct
#ifdef __APPLE__
__attribute__ ((packed))
#endif
{
    unsigned char idSize,mapType,imageType;
    unsigned short paletteStart,paletteSize;
    unsigned char paletteEntryDepth;
    unsigned short x,y,width,height;
    unsigned char colorDepth,descriptor;
    
} TgaHeader;



#endif /* TGAHeader_h */

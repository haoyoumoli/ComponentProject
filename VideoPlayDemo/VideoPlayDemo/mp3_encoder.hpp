//
//  mp3_encoder.hpp
//  VideoPlayDemo
//
//  Created by apple on 2022/3/25.
//

#ifndef mp3_encoder_hpp
#define mp3_encoder_hpp

#include <stdio.h>
#include "fat-lame/include/lame/lame.h"

class Mp3Encoder {
private:
    FILE *pcmFile;
    FILE *mp3File;
    lame_t lameClient;
public:
    Mp3Encoder();
    ~Mp3Encoder();
    int Init(const char* pcmFilePath,const char *mp3FilePath,int sampleRate,int channels,int bitRate);
    void Encode();
    void Destory();
};
#endif /* mp3_encoder_hpp */

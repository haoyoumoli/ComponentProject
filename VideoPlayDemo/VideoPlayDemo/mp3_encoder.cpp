//
//  mp3_encoder.cpp
//  VideoPlayDemo
//
//  Created by apple on 2022/3/25.
//

#include "mp3_encoder.hpp"




int Mp3Encoder::Init(const char* pcmFilePath,const char *mp3FilePath,int sampleRate,int channels,int bitRate) {
    int ret = -1;
    pcmFile = fopen(pcmFilePath, "rb");
    if (pcmFile) {
        mp3File = fopen(mp3FilePath, "wb");
        if (mp3File) {
            lameClient  = lame_init();
            //设置采样率
            lame_set_in_samplerate(lameClient, sampleRate);
            lame_set_out_samplerate(lameClient, sampleRate);
            //设置声道数
            lame_set_num_channels(lameClient, channels);
            //设置码率(每秒bit数)
            lame_set_brate(lameClient, bitRate);
            lame_init_params(lameClient);
            ret = 0;
        }
    }
    return ret;
}

void Mp3Encoder::Encode() {
    int bufferSize = 1024 * 256;
    short* buffer = new short[bufferSize / 2];
    short* leftBuffer = new short[bufferSize / 4];
    short* rightBuffer = new short[bufferSize / 4];
    unsigned char* mp3_buffer = new unsigned char[bufferSize];
    size_t readBufferSize = 0;
    //循环读取pcmfile,编码写入mp3 file
    while ((readBufferSize = fread(buffer, 2, bufferSize / 2, pcmFile)) > 0) {
        for (int i = 0; i < readBufferSize;i++) {
            if (i % 2 == 0) {
                leftBuffer[i / 2] = buffer[i];
            } else {
                rightBuffer[i / 2] = buffer[i];
            }
        }
        size_t wroteSize = lame_encode_buffer(lameClient, (short int *)leftBuffer, (short int*)rightBuffer, (int)(readBufferSize / 2), mp3_buffer, bufferSize);
        fwrite(mp3_buffer, 1, wroteSize, mp3File);
    }
    
    delete[] buffer;
    delete[] leftBuffer;
    delete[] rightBuffer;
    delete[] mp3_buffer;
}


void Mp3Encoder::Destory() {
    if (pcmFile) {
        fclose(pcmFile);
    }
    if (mp3File) {
        fclose(mp3File);
        lame_close(lameClient);
    }
}

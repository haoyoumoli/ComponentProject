//
//  CStruct.h
//  FIleDemo
//
//  Created by apple on 2021/10/27.
//

#ifndef CStruct_h
#define CStruct_h


typedef struct
__attribute__ ((packed)) //告诉编译器使用紧凑模式,禁用内存对齐
{
    unsigned char v1;
    unsigned int v2;
    unsigned char v3;
} CStruct1;


#endif /* CStruct_h */

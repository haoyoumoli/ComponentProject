//
//  EGL.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/23.
//

import Foundation
import OpenGLES


//MARK: -
///EGL 是 OpenGL 和原生窗口系统通信的API
///注意: Apple 有自己的EGL API 成为 EAGL

struct Chapter2 {
    static func initialize() {
        var majorVersion:UInt32 = 0
        var minorVersion:UInt32 = 0
        
        EAGLGetVersion(&majorVersion, &minorVersion)
        
        //        EAGLDrawable
    }
    
}

//MARK: -
struct Chapter3 {
    
    ///查询统一活动变量
    static func lookUpUniformValues(program:GLuint) {
        
        ///查询有多少统一活动变量
        var numUniforms:GLint = 0
        glGetProgramiv(program, GLenum(GL_ACTIVE_UNIFORMS), &numUniforms)
        
        var maxUniformsLen:GLint = 0
        glGetProgramiv(program, GLenum(GL_ACTIVE_UNIFORM_MAX_LENGTH), &maxUniformsLen);
        
        let uniformName = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(maxUniformsLen))
        
        let maxUniformsLen2 = maxUniformsLen
        defer {
            uniformName.deinitialize(count: Int(maxUniformsLen2))
            uniformName.deallocate()
        }
        
        var index:GLuint = 0
        while index < numUniforms {
            
            var size:GLint = 0
            var type:GLenum =  0
            
            /// 获取统一活动变量信息
            glGetActiveUniform(program,index, maxUniformsLen, nil, &size, &type, uniformName)
            
            /// 获取位置
            let location:GLint = glGetUniformLocation(program, uniformName)
            
            if type == GLenum(GL_FLOAT) {
                
            }
            else if type == GLenum(GL_FLOAT_VEC2) {
                
            }
            else if type == GLenum(GL_FLOAT_VEC3) {
                
            }
            else if type == GLenum(GL_FLOAT_VEC4) {
                
            }
            else if type == GLenum(GL_INT) {
                
            } else {
                //unkown type
            }
            
            
            index += 1
        }
    }
    
    
    ///为统一变量块LightBlock建议一个统一变量缓冲区
    ///OPENGL ES 3.0  编程指南 P100
    ///layout (std140) uniform LightBlock
    ///{
    ///  vec3 lightDirection;
    ///  vec4 lightPosition;
    ///};
    static func createUniformBlockBufferForLightBlock(program:GLuint) {
        ///P 103
        let lightData:[GLfloat] = [
            //lightDirection (padded to vec4 based on std140 rule)
            // P100 对 std140 对齐规则有说明
            1.0, 0.0, 0.0, 0.0,
            
            //lightPosition
            0.0, 0.0, 0.0, 1.0
        ]
        
        //获取统一变量的索引
        let blockId:GLuint = "LightBlock".withCString {
            glGetUniformBlockIndex(program, $0)
        }
        
        //Associate the uniform block index with a binding point
        let bindingPoint:GLuint = 1;
        glUniformBlockBinding(program, blockId, bindingPoint)
        
        //Get the size of lightData, alternatively
        //We can calculate if using sizeof(lighData) in this example
        var blockSize:GLint = 0
        glGetActiveUniformBlockiv(program, blockId, GLenum(GL_UNIFORM_BLOCK_DATA_SIZE), &blockSize)
        
        //Create and fill a buffer object
        var bufferId:GLuint = 0
        glGenBuffers(1, &bufferId)
        glBindBuffer(GLenum(GL_UNIFORM_BUFFER), bufferId)
        glBufferData(GLenum(GL_UNIFORM_BUFFER), GLsizeiptr(blockSize), lightData, GLenum(GL_DYNAMIC_DRAW))
        
        
        //Bind the buffer object to the uniform block binding point
        glBindBufferBase(GLenum(GL_UNIFORM_BUFFER), bindingPoint, bufferId)
        
        
        
    }
}


//MARK: -
struct Chapter6 {
    
    static func main() {
        let progromId: GLint = 0
        
        ///查询 支持的顶点属性数量
        var maxVertexAttribs:GLint = 0 // will be >= 16
        glGetIntegerv(GLenum(GL_MAX_VERTEX_ATTRIBS), &maxVertexAttribs)
        
        var activeAttribs:GLint = 0
        glGetProgramiv(GLenum(progromId), GLenum(GL_ACTIVE_ATTRIBUTES), &activeAttribs)
        
        /**
         OpenGL 缓冲区
         GL_ARRAY_BUFFER 创建保存顶点数据的对象
         GL_ELEMENT_ARRAY_BUFFER 用于创建保存图元索引
         */
        
    }
    
    ///使用和不适用顶点缓冲区对象进行绘制 VBO
    static func usingOrNotVertexBufferDraw() {
        let vertex_pos_size:GLint = 3
        let vertex_color_size:GLint = 4
        let vertex_pos_indx:GLuint = 0
        let vertex_color_indx:GLuint = 1
        
        func drawPrimitiveWithoutVBOs
        (vertices:[GLfloat],
         vtxStride:GLint,
         numIndices:GLint,
         indices:[GLushort])
        {
            var vtxBuf = vertices
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
            
            glEnableVertexAttribArray(vertex_pos_indx)
            glEnableVertexAttribArray(vertex_color_indx)
            
            
            //会发生数据的复制,每一次绘制都会发生复制
            glVertexAttribPointer(vertex_pos_indx, vertex_pos_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vtxStride, &vtxBuf)
            
            
            vtxBuf.withUnsafeBufferPointer { pointer in
                if pointer.baseAddress != nil {
                    glVertexAttribPointer(vertex_color_indx, vertex_color_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vtxStride, (pointer.baseAddress! + Int(vertex_pos_size)))
                }
            }
            
            glDrawElements(GLenum(GL_TRIANGLES), numIndices, GLenum(GL_UNSIGNED_SHORT), UnsafeRawPointer(bitPattern: 0))
            
            
            glDisableVertexAttribArray(vertex_pos_indx)
            glDisableVertexAttribArray(vertex_color_indx)
        }
        
        
        func drawPrimitiveWithVBOS(
            boIds:[GLuint],
            numVertices:GLint,
            vtxBuf:[GLfloat],
            vtxStride:GLint,
            numIndices:GLint,
            indices:[GLushort]
        ) {
            
            var vtxBuf = vtxBuf
            var indices = indices
            
            var vboIds:[GLuint] = .init(repeating: 0, count: 2)
            
            
            if  vboIds.count >= 2 ,
                vboIds[0] == 0 ,
                vboIds[1] == 0 {
                glGenBuffers(2, &vboIds)
                
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboIds[0])
                ///把数据拷贝到缓冲区(GPU)
                glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vtxStride * numVertices), &vtxBuf, GLenum(GL_STATIC_DRAW))
                
                
                
                glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vboIds[1])
                ///把数据拷贝到缓冲区(GPU)
                glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(numIndices * GLint(MemoryLayout<GLuint>.stride)), &indices, GLenum(GL_STATIC_DRAW))
                
                
            }
            
            if vboIds.count >= 2 {
                
                var offset: GLint = 0
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), boIds[0])
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), boIds[1])
                
                glEnableVertexAttribArray(vertex_pos_indx)
                glEnableVertexAttribArray(vertex_color_indx)
                
                
                ///指定数据的读取方式
                glVertexAttribPointer(vertex_pos_indx, vertex_pos_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vtxStride, UnsafeRawPointer(bitPattern: 0))
                
            
                
                
                ///指定数据的读取方式
                glVertexAttribPointer(vertex_color_indx, vertex_color_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vtxStride, UnsafeMutablePointer(bitPattern: Int(vertex_pos_size) * MemoryLayout<GLfloat>.stride))
                
                
                glDrawElements(GLenum(GL_TRIANGLES), numIndices,GLenum(GL_UNSIGNED_SHORT), UnsafeRawPointer(bitPattern: 0))
                
                glDisableVertexAttribArray(vertex_pos_indx)
                glDisableVertexAttribArray(vertex_color_indx)
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
                glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
                
            }
            
            
            
        }
        
        
        func draw(programObject:GLuint) {
            
            let vertices:[GLfloat] = [
                -0.5,  0.5,  0.0,        //v0
                 1.0,  0.0,  0.0, 1.0,   //c0
                -1.0, -0.5,  0.0,        //v1
                 0.0,  1.0,  0.0, 1.0,   //c1
                 0.0, -0.5,  0.0,        //v2
                -0.5,  0.5,  1.0, 1.0    //c2
            ]
            
            
            let indices:[GLushort] = [0, 1 ,2]
            
            glViewport(0, 0, 320, 480)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            glUseProgram(programObject)
            
            let offsetLoc:GLint = 0
            glUniform1f(offsetLoc, 0.0)
            
            let vtxStride = GLint(MemoryLayout<GLfloat>.stride) * (vertex_pos_size + vertex_color_size)
            
            drawPrimitiveWithoutVBOs(vertices: vertices,
                                     vtxStride: vtxStride,
                                     numIndices: GLint(indices.count),
                                     indices: indices)
            
            glUniform1f(offsetLoc, 1.0)
            
            let boids:[GLuint] = .init(repeating: 0, count: 2)
            drawPrimitiveWithVBOS(boIds: boids, numVertices: 3, vtxBuf: vertices, vtxStride: vtxStride, numIndices: GLint(indices.count), indices: indices)
        }
        
        
        ///每个顶点属性使用单独的缓冲区对象
        func drawPromitiveWithVBOs2(  boIds:[GLuint],numVertices:GLint,vtxBuff:[[GLfloat]],vtxStrides:[GLint],numIndices:GLint,indices:[GLushort])
        {
            if boIds.count >= 3,
               vtxStrides.count == boIds.count,
               boIds[0] == 0,
               boIds[1] == 0,
               boIds[2] == 0 {
                
                var boIds = boIds
                var vtxBuff = vtxBuff
                var indices = indices
                
                glGenBuffers(3, &boIds)
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), boIds[0])
                glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vtxStrides[0] * numVertices), &vtxBuff[0], GLenum(GL_STATIC_DRAW))
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), boIds[1])
                glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vtxStrides[1] * numVertices), &vtxBuff[1], GLenum(GL_STATIC_DRAW))
                
            
                glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), boIds[2])
                glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(GLint(MemoryLayout<GLushort>.stride) * numIndices), &indices, GLenum(GL_STATIC_DRAW))
                
            }
            
            if boIds.count == 3,
               vtxStrides.count == boIds.count {
                
                var offSet:GLint = 0
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), boIds[0])
                glEnableVertexAttribArray(vertex_pos_indx)
                glVertexAttribPointer(vertex_pos_indx, vertex_pos_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vtxStrides[0], &offSet)
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), boIds[1])
                glEnableVertexAttribArray(GLenum(vertex_color_indx))
                glVertexAttribPointer(vertex_pos_indx, vertex_pos_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vtxStrides[1], &offSet)
                
                glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), boIds[2])
                glDrawElements(GLenum(GL_TRIANGLES), numIndices, GLenum(GL_UNSIGNED_SHORT), &offSet)
                
                glDisableVertexAttribArray(vertex_pos_indx)
                glDisableVertexAttribArray(vertex_color_indx)
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
                
            }
            
            ///结束的渲染缓冲区的使用后可以对其删除
            var boIds = boIds
            glDeleteBuffers(GLsizei(boIds.count), &boIds)
            
            ///VBO , VAO
        }
        
        
    }
    
    
    static func drawUsingVAO() {
        
        let vertex_pos_size:GLint = 3
        let vertex_color_size:GLint = 4
        let vertex_pos_indx:GLuint = 0
        let vertex_color_indx:GLuint = 1
        let vertex_stride:GLint = GLint( MemoryLayout<GLfloat>.stride) * (vertex_pos_size + vertex_color_size)
        
        
        let vShaderStr = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec4 a_color;
        out vec4 v_color;
        void main()
        {
            v_color = a_color;
            gl_Position = a_position;
        }
        """
        
        let fShaderStr = """
        #version 300 es
        precision mediump float;
        in vec4 v_color;
        out vec4 o_fragcColor;
        void main()
        {
            o_fragColor = v_color;
        }
        """
        
        let shaderComplier = ShaderCompiler.init(vertexShaderCode: vShaderStr, fragmentShaderCode: fShaderStr)
        
        var programObject:GLuint = 0
        do {
            let shaders = try shaderComplier.complie().get()
            
            programObject = try shaderComplier.link(vertexShader: shaders.vertexShader, fragmentShader: shaders.fragmentShader).get()
            
        } catch  {
            return
        }
        
        var vertices:[GLfloat] = [
            -0.5,  0.5,  0.0,        //v0
             1.0,  0.0,  0.0, 1.0,   //c0
            -1.0, -0.5,  0.0,        //v1
             0.0,  1.0,  0.0, 1.0,   //c1
             0.0, -0.5,  0.0,        //v2
            -0.5,  0.5,  1.0, 1.0    //c2
        ]
      
        var indices:[GLushort] = [0,1,2]
        
        var vboIds:[GLuint] = [0,0]
        glGenBuffers(2, &vboIds)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboIds[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.stride * vertices.count), &vertices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vboIds[1])
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLushort>.stride * indices.count), &indices, GLenum(GL_STATIC_DRAW))
        
        var vaoId:GLuint = 0
        glGenVertexArrays(1, &vaoId)
        
        glBindVertexArray(vaoId)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboIds[0])
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vboIds[1])
        
        glEnableVertexAttribArray(vertex_pos_indx)
        glEnableVertexAttribArray(vertex_color_indx)
        
        glVertexAttribPointer(vertex_pos_indx, vertex_pos_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vertex_stride, UnsafeRawPointer(bitPattern: 0))
        
        glVertexAttribPointer(vertex_color_indx, vertex_color_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vertex_stride, UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * Int(vertex_pos_size)))
        
        //Reset to the default vao
        glBindVertexArray(0)
        glClearColor(0.0, 0.0, 0.0, 0.0)
    }
    
    
    ///读取opengl 缓冲区数据, 从GPU 拷贝带CPU
    ///P148
    static func getDataFromOpenGLESBuffer() {
        

        var vboids:[GLuint] = .init(repeating: 0, count: 2)
        glGenBuffers(2, &vboids)
        
        let vtxStride:GLuint = 0
        let numVertices:GLuint = 0
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboids[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vtxStride * numVertices), nil, GLenum(GL_STATIC_DRAW))
        
        
        let vtxMappedBuf = glMapBufferRange(GLenum(GL_ARRAY_BUFFER), 0, GLsizeiptr(vtxStride * numVertices), GLbitfield(GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT))
        
        if (vtxMappedBuf == nil) {
            debugPrint("Error mapping vertext buffer object.")
            return
        }
        
        //Copy the data into the mapped buffer
        vtxMappedBuf?.copyMemory(from: vtxMappedBuf!, byteCount: Int(numVertices * vtxStride))
        defer { vtxMappedBuf?.deallocate() }
        
        //Unmap the buffer
        if (glUnmapBuffer(GLenum(GL_ARRAY_BUFFER)) == GL_FALSE) {
            debugPrint("Error unmapping array buffer object.")
            return
        }
        
        
        //Map the index buffer
        let numIndices = 0
        let indicesSize = MemoryLayout<GLushort>.stride * numIndices
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vboids[1])
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indicesSize , nil, GLenum(GL_STATIC_DRAW))
        
        
        let idxMappedBuf = glMapBufferRange(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0, indicesSize, GLbitfield(GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT))
        
        if idxMappedBuf == nil {
            debugPrint("Error mapping element buffer object.")
            return
        }
        
        idxMappedBuf?.copyMemory(from: idxMappedBuf!, byteCount: indicesSize)
        
        if (glUnmapBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER)) == GL_FALSE) {
            
            debugPrint("Error unmapping element buffer object.")
            return
        }
    }
}

//MARK: - 
struct Chapter7 {
    
}


//MARK: - 第8章 顶点着色器
struct Chapter8 {
   
}

//MARK: - 第9章 纹理
struct Chapter9 {
    
    static func printSupportedCompressedTextureFormats() {
        var count:GLint =  0
        glGetIntegerv(GLenum(GL_NUM_COMPRESSED_TEXTURE_FORMATS), &count)
        
        if count == 0 {
            debugPrint("不支持压缩的纹理")
            return
        }
        
        var formats:[GLint] = .init(repeating: 0, count: Int(count))
        glGetIntegerv(GLenum(GL_COMPRESSED_TEXTURE_FORMATS), &formats)
        
        debugPrint("支持的纹理格式:\(formats)")
    }
    
    
}

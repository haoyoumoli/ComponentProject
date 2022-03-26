//
//  MRTDemo.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/10/27.
//

import Foundation
import OpenGLES
/**
 1.先在缓冲区绘制纹理
 2.再将纹理拷贝到制定的帧缓冲区矩形区域,帧缓冲区的左下角多表为(0,0)
 */
class MRTDemo:DemoProtocol {
    
    let programObject:GLuint
    
    //userdatas
    lazy private(set) var fbo: GLuint = 0
    lazy private(set) var colorTexId = [GLuint].init(repeating: 0, count: 4)
    lazy private(set) var attachments:[GLenum] = [
        GLenum(GL_COLOR_ATTACHMENT0),
        GLenum(GL_COLOR_ATTACHMENT1),
        GLenum(GL_COLOR_ATTACHMENT2),
        GLenum(GL_COLOR_ATTACHMENT3),
    ]
    lazy private(set) var textureWidth:GLsizei = 0
    lazy private(set) var textureHeight:GLsizei = 0
    
    required init?() {
        let verticesShader = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        void main() {
            gl_Position = a_position;
        }
        """
        
        let fragmentShader = """
        #version 300 es
        precision mediump float;
        layout(location = 0) out vec4 fragData0;
        layout(location = 1) out vec4 fragData1;
        layout(location = 2) out vec4 fragData2;
        layout(location = 3) out vec4 fragData3;
        void main() {
            fragData0 = vec4(1,0,0,1);
            fragData1 = vec4(0,1,0,1);
            fragData2 = vec4(0,0,1,1);
            fragData3 = vec4(0.5,0.5,0.5,1);
        }
        """
        
        let shaderCompiler = ShaderCompiler(vertexShaderCode: verticesShader, fragmentShaderCode: fragmentShader)
        
        guard
            let compilerResult = try? shaderCompiler.complie().get(),
            let programObject = try? shaderCompiler.link(compilerResult).get()
        else { return nil }
        self.programObject = programObject
        
        if initFBO() == false { return nil }
        
        glClearColor(1.0, 1.0, 1.0, 0.0)
    }
    
    func draw(width: Int, height: Int) {
        var defaultFrameBuffer:GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &defaultFrameBuffer)
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glDrawBuffers(GLsizei(attachments.count), &attachments)
        
        ///draw geometry
        var vVertices:[GLfloat] = [
            -1.0,  1.0, 0.0,
            -1.0, -1.0, 0.0,
             1.0, -1.0, 0.0,
             1.0,  1.0, 0.0,
        ]
        var indices:[GLushort] = [0,1,2,0,2,3]
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glUseProgram(programObject)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3), &vVertices)
        glEnableVertexAttribArray(0);
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_SHORT), &indices)
        
        
        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), GLuint(defaultFrameBuffer))
        
        //blit texture
        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), fbo)
        
        //copy the output of red buffer to lower left quadrant
        glReadBuffer(attachments[0])
        glBlitFramebuffer(0, 0, textureWidth, textureHeight,
                          0, 0, GLsizei(width / 2) ,  GLsizei(height / 2), GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_LINEAR))
        
        // Copy the output green buffer to lower right quadrant
        glReadBuffer(attachments[1])
        glBlitFramebuffer(0, 0, textureWidth, textureHeight,
                          GLsizei(width / 2), 0, GLsizei(width), GLsizei(height / 2),
                          GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_LINEAR))
        
        // Copy the output blue buffer to upper left quadrant
        glReadBuffer(attachments[2])
        glBlitFramebuffer(0, 0, textureWidth, textureHeight,
                          0, GLsizei(height / 2), GLsizei(width / 2), GLsizei(height),
                          GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_LINEAR))

        // Copy the output gray buffer to upper right quadrant
        glReadBuffer(attachments[3])
        glBlitFramebuffer(0, 0, textureWidth, textureHeight,
                         GLsizei(width / 2),GLsizei(height / 2), GLsizei(width), GLsizei(height),
                          GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_LINEAR))
        
       
    }
    
    func shutDown() {
        glDeleteProgram(programObject)
        glDeleteTextures(GLsizei(colorTexId.count), &colorTexId)
        glDeleteFramebuffers(1, &fbo)
    }
    
}

fileprivate extension MRTDemo {
    func initFBO() -> Bool {
       
        ///先获取之前的绑定
        var defaultFrameBuffer:GLint = 0
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &defaultFrameBuffer)
        
        glGenFramebuffers(1, &fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo)
        
        textureWidth = 400
        textureHeight = 400
        
        glGenTextures(GLsizei(colorTexId.count), &colorTexId)
        
        for i in 0..<4 {
            ///绑定id
            glBindTexture(GLenum(GL_TEXTURE_2D), colorTexId[i])
            
            ///传递数据
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, textureWidth, textureHeight, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
            
            ///设置纹理选项
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
            
            glFramebufferTexture2D(GLenum(GL_DRAW_FRAMEBUFFER), attachments[i], GLenum(GL_TEXTURE_2D), colorTexId[i], 0)
        }
        
        glDrawBuffers(4, &attachments)
        
        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            return false
        }
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(defaultFrameBuffer));
        return true
        
    }
    
   
}

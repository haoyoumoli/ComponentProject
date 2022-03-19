//
//  SimpleTexture2D.swift
//  LayoutDemo2
//
//  Created by apple on 2021/8/17.
//

import Foundation
import OpenGLES

final class SimpleTexture2D:DemoProtocol {
    
    private(set) var programObject:GLuint = 0
    private(set) var samplerLoc:GLint = 0
    private(set) var textureId:GLuint = 0
    
    init?() {
        let vShaderStr = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec2 a_texCoord;
        out vec2 v_texCoord;
        void main() {
            v_texCoord = a_texCoord;
            gl_Position = a_position;
        }
        """
        
        let fShaderStr = """
        #version 300 es
        precision mediump float;
        in vec2 v_texCoord;
        layout(location = 0) out vec4 outColor;
        uniform sampler2D s_texture;
        void main() {
            outColor = texture(s_texture,v_texCoord);
        }
        """
        
        let shaderCompiler = ShaderCompiler.init(vertexShaderCode: vShaderStr, fragmentShaderCode: fShaderStr)
        do {
            let result = try shaderCompiler.complie().get()
            programObject = try shaderCompiler.link(result).get()
        } catch {
            return nil
        }
        
        "s_texture".withCString { p in
            let pointer:UnsafePointer<GLchar>? = p
            glGetUniformLocation(programObject, pointer)
        }
        
        textureId = SimpleTexture2D.createSimpleTexture2D()
        
        glClearColor(1.0, 1.0, 1.0, 0.0)
        
      
    }
    
    
    deinit {
        shutDown()
    }
    
    func draw(width: Int, height: Int) {
        
        var vVertices:[GLfloat] = [
            -0.5,  0.5, 0.0,  // Position 0
            0.0,  0.0,        // TexCoord 0
            -0.5, -0.5, 0.0,  // Position 1
            0.0,  1.0,        // TexCoord 1
            0.5, -0.5, 0.0,  // Position 2
            1.0,  1.0,        // TexCoord 2
            0.5,  0.5, 0.0,  // Position 3
            1.0,  0.0         // TexCoord 3
        ]
        
        var indices:[GLushort] = [0,1,2,0,2,3]
        
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glUseProgram(programObject)
        
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 5), &vVertices)
        vVertices.withUnsafeBufferPointer { pointer  in
            glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 5), pointer.baseAddress! + 3)
        }
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        
        // Set the sampler texture unit to 0
        glUniform1i(samplerLoc, 0)
        
        glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_SHORT), &indices)
        
    }
    
    func shutDown() {
        glDeleteTextures(1, &textureId)
        glDeleteProgram(programObject)
    }
}

extension SimpleTexture2D {
    static func createSimpleTexture2D() -> GLuint {
        var textureId:GLuint = 0
        
        var pixels:[GLubyte] = [
            255,0,0, //red
            0,255,0, //green
            0,0,255, //blue
            255,255,0 //yello
        ]
        
        //Use tightly packed data
        //在调用glTexImage2D之前,调用glPixelStorei设置解包对齐方式
        //这里设置的1个字节对齐
        glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
        
        //生成纹理id
        glGenTextures(1, &textureId)
        //设置纹理id为2d纹理
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        //传递纹理数据
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, 2, 2, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &pixels)
        
        //设置过滤模式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        
        return textureId
        
    }
}

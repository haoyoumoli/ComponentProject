//
//  TextureWrapDemo.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/17.
//

import Foundation
import OpenGLES

final class TextureWrapDemo: DemoProtocol {
    
    private(set) var programObject:GLuint = 0
    
    private(set) var samplerLoc:GLint = 0
    
    private(set) var offsetLoc: GLint = 0
    
    private(set) var textureId: GLuint = 0
    
    init?() {
        let vShaderStr = """
        #version 300 es
        uniform float u_offset;
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec2 a_texCoord;
        out vec2 v_texCoord;
        void main()
        {
            gl_Position = a_position;
            gl_Position.x += u_offset;
            v_texCoord = a_texCoord;
        }
        """
        
        let vFragShaderStr = """
        #version 300 es
        precision mediump float;
        in vec2 v_texCoord;
        layout(location = 0) out vec4 outColor;
        uniform sampler2D s_texture;
        void main()
        {
            outColor = texture(s_texture ,v_texCoord);
        }
        """
        
        let shaderComplier = ShaderCompiler(vertexShaderCode: vShaderStr, fragmentShaderCode: vFragShaderStr)
        
        do {
            let result = try shaderComplier.complie().get()
            programObject = try shaderComplier.link(result).get()
        } catch {
            return nil
        }
        
        "s_texture".withCString { p in
            let pointer:UnsafePointer<GLchar>? = p
            samplerLoc = glGetUniformLocation(programObject, pointer)
        }
        
        "u_offset".withCString { p in
            let pointer:UnsafePointer<GLchar>? = p
            offsetLoc = glGetUniformLocation(programObject, pointer)
        }
        
        textureId = TextureWrapDemo.createTexture2D()
        
        glClearColor(1.0, 1.0, 1.0, 0.0)
        
    }
    
    deinit {
        shutDown()
    }
    
    func draw(width: Int, height: Int) {
        
        var vVertices:[GLfloat] = [
            -0.3,  0.3, 0.0, 1.0,  // Position 0
            -1.0,  -1.0,           // TexCoord 0
            
            -0.3, -0.3, 0.0, 1.0,  // Position 1
            -1.0,  2.0,            // TexCoord 1
            
            0.3, -0.3, 0.0, 1.0,   // Position 2
            2.0,  2.0,             // TexCoord 2
            
            0.3,  0.3, 0.0, 1.0,   // Position 3
            2.0,  -1.0             // TexCoord 3
        ]
        
        var indices:[GLushort] = [0,1,2,0,2,3]
        
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glUseProgram(programObject)

    
        glVertexAttribPointer(0, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 6), &vVertices)
        
        vVertices.withUnsafeBufferPointer { pointer in
            glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 6), pointer.baseAddress! + 4)
        }
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        // Set the sampler texture unit to 0
        glUniform1i(samplerLoc, 0)
        
        //Draw quad with repeat wrap mode
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), (GL_REPEAT))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), (GL_REPEAT))
        glUniform1f(offsetLoc,-0.7)
        glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_SHORT), &indices)
        
        //Draw quad with clamp to edge wrap mode
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), (GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), (GL_CLAMP_TO_EDGE))
        glUniform1f(offsetLoc,0.0)
        glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_SHORT), &indices)


        //Draw quad with mirrored repeat
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), (GL_MIRRORED_REPEAT))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), (GL_MIRRORED_REPEAT))
        glUniform1f(offsetLoc,0.7)
        glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_SHORT), &indices)
 
        debugPrint(glGetError())
    }
    
    func shutDown() {
        glDeleteProgram(programObject)
        glDeleteTextures(1, &textureId)
    }
}

extension TextureWrapDemo {
    
    static func genCheckImage(width:Int,height:Int,checkSize:Int) -> [GLubyte] {
        
        let bytesCount  = width * height * 3
        
        var pixels = [GLubyte].init(repeating: 0, count: bytesCount)
        
        for h in 0..<height {
            
            for w in 0..<width {
                
                var rColor = GLubyte(0)
                
                var bColor = GLubyte(0)
                
                if (w / checkSize) % 2 == 0 {
                    rColor = GLubyte(255 * (( h / checkSize) % 2))
                    bColor = GLubyte(255 * (1 - ((h / checkSize) % 2)))
                }
                else {
                    bColor = GLubyte(255 * (( h / checkSize) % 2))
                    rColor = GLubyte(255 * (1 - ((h / checkSize) % 2)))
                }
                
                pixels[(h * width + w) * 3] = rColor
                pixels[(h * width + w) * 3 + 1] = 0
                pixels[(h * width + w) * 3 + 2] = bColor
            }
        }
        
        return pixels
    }
    
    static func createTexture2D() -> GLuint {
        var textureId:GLuint = 0
        
        let width = 256,height = 256
        
        var pixels = genCheckImage(width: width, height: height, checkSize: 64)
        
        glGenTextures(1, &textureId)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &pixels)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        
        return textureId
        
    }
}

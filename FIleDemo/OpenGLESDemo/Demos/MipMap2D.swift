//
//  MipMap2D.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/16.
//

import Foundation
import OpenGLES

final class MipMap2DDemo:DemoProtocol {
    
    private(set) var  programObject:GLuint = 0
    private(set) var  samplerLoc:GLint = 0
    private(set) var  offsetLoc:GLint = 0
    private(set) var  textureId:GLuint = 0
    
    
    init?() {
        let vShaderStr = """
        #version 300 es
        uniform float u_offset;
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec2 a_textcoord;
        out vec2 v_texCoord;
        void main()
        {
            gl_Position = a_position;
            gl_Position.x += u_offset;
            v_texCoord = a_textcoord;
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
            samplerLoc = glGetUniformLocation(programObject, p)
        }
        
        "u_offset".withCString { p in
            offsetLoc = glGetUniformLocation(programObject, p)
        }
        
        textureId = MipMap2DDemo.createMipMappedTexture2D()
        
        glClearColor(1.0, 1.0, 1.0, 0.0)
    }
    
    deinit {
        shutDown()
    }
    
    func draw(width: Int, height: Int) {
        var vVertices:[GLfloat] = [
            -0.5, 0.5, 0.0, 1.5,     // Position 0
             0.0,  0.0,              // TexCoord 0
            -0.5, -0.5, 0.0, 0.75,   // Position 1
             0.0,  1.0,              // TexCoord 1
             0.5, -0.5, 0.0, 0.75,   // Position 2
             1.0,  1.0,              // TexCoord 2
             0.5,  0.5, 0.0, 1.5,    // Position 3
             1.0,  0.0               // TexCoord 3
        ]
        
        var indices:[GLushort] = [  0, 1, 2, 0, 2, 3]
        
        glViewport(0, 0,GLsizei(width), GLsizei(height))
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(programObject)
        
        glVertexAttribPointer(0, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE),GLsizei( MemoryLayout<GLfloat>.stride * 6), &vVertices)
        
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei( MemoryLayout<GLfloat>.stride * 6), &vVertices)
        
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        
        //绑定纹理
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE0), textureId)
        
        // Set the sampler texture unit to 0
        glUniform1i(samplerLoc, 0)
        
        
        // Draw quad with nearest sampling
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glUniform1f(offsetLoc, -0.6)
        glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_SHORT), &indices)
        
        // Draw quad with trilinear filtering
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
        glUniform1f(offsetLoc, 0.6)
        glDrawElements(GLenum(GL_TRIANGLES), 6,GLenum(GL_UNSIGNED_SHORT),&indices)
    }
    
    func shutDown() {
        glDeleteProgram(programObject)
        glDeleteTextures(1, &textureId)
        
    }
    
}

//MARK: -
extension MipMap2DDemo {
    static func createMipMappedTexture2D() -> GLuint {
        
        var width = 256
        var height = 256
        
        // 生成纹理(像素buffer)
        var pixels = genCheckImage(width: width, height: height, checkSize: 8)
        
        if pixels.count == 0 { return 0 }
        
        var textureId:GLuint = 0
        
        //生成纹理id
        glGenTextures(1, &textureId)
        
        //设置纹理属性为2d
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        
        //使OpenGL 加载纹理,并制定 level 为0
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &pixels)
        
        var level = 1
        
        var prevImage = pixels
        
        while width > 1 && height > 1 {
            var newWidth = 0
            var newHeight = 0
            
            var newImage = genMipMap2D(src: prevImage, srcWidth: width, srcHeight: height, dstWidth: &newWidth, dstHeight: &newHeight)
            
            glTexImage2D(GLenum(GL_TEXTURE_2D), GLint(level), GL_RGB, GLsizei(newWidth), GLsizei(newHeight), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &newImage)
            
            prevImage = newImage
            level += 1
            
            width = newWidth
            height = newHeight
        }
        
        return textureId
    }
    
    //生成下一级纹理mip贴图
    static func genMipMap2D(src: [GLubyte],srcWidth:Int,srcHeight:Int,dstWidth: inout Int,dstHeight: inout Int) -> [GLubyte] {
        let texelSize = 3
        
        dstWidth = srcWidth / 2
        if dstWidth <= 0 {
            dstWidth = 1
        }
        
        dstHeight = srcHeight / 2
        if dstHeight <= 0 {
            dstHeight = 1
        }
        
        var dst = [GLubyte].init(repeating: 0, count: texelSize * dstWidth * dstHeight)
        
        
        for y in 0..<dstHeight {
            for x in 0..<dstWidth {
                var srcIndex = [Int].init(repeating: 0, count: 4)
                var r:Float = 0.0
                var g:Float = 0.0
                var b:Float = 0.0
                // Compute the offsets for 2x2 grid of pixels in previous
                // image to perform box filter
                srcIndex[0] =
                    ( ( ( y * 2 ) * srcWidth ) + ( x * 2 ) ) * texelSize
                srcIndex[1] =
                    ( ( ( y * 2 ) * srcWidth ) + ( x * 2 + 1 ) ) * texelSize
                srcIndex[2] =
                    ( ( ( ( y * 2 ) + 1 ) * srcWidth ) + ( x * 2 ) ) * texelSize
                srcIndex[3] =
                    ( ( ( ( y * 2 ) + 1 ) * srcWidth ) + ( x * 2 + 1 ) ) * texelSize
                
                // Sum all pixels
                for sample in 0..<4 {
                    r += Float(src[srcIndex[sample]])
                    g += Float(src[srcIndex[sample] + 1])
                    b += Float(src[srcIndex[sample] + 2])
                }
                
                // Average results
                r /= 4.0
                g /= 4.0
                b /= 4.0
                
                dst[(y * dstWidth + x) * texelSize] = GLubyte(r)
                dst[(y * dstWidth + x) * texelSize + 1] = GLubyte(g)
                dst[(y * dstWidth + x) * texelSize + 2] = GLubyte(b)
                
            }
        }
        return dst
    }
    
    
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
}

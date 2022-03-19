//
//  MutilTexture.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/10/26.
//

import UIKit


final class MutilTextureDemo:DemoProtocol {
    
    let programObject:GLuint
    
    private(set) var baseMapLoc: GLint = 0
    private(set) var lightMapLoc: GLint = 0
    
    private(set) var baseMapTexId: GLuint = 0
    private(set) var lightMapTexId: GLuint = 0
    
    init?() {
        
        let vertexShaderStr = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec2 a_texCoord;
        out vec2 v_texCoord;
        void main()
        {
            gl_Position = a_position;
            v_texCoord = a_texCoord;
        }
        """
        
        let fragmentShader = """
        #version 300 es
        precision mediump float;
        in vec2 v_texCoord;
        layout(location = 0) out vec4 outColor;
        uniform sampler2D s_baseMap;
        uniform sampler2D s_lightMap;
        void main() {
            vec4 baseColor;
            vec4 lightColor;
            baseColor = texture(s_baseMap,v_texCoord);
            lightColor = texture(s_lightMap,v_texCoord);
            outColor = baseColor * (lightColor + 0.25);
        }
        """
        
        let compiler = ShaderCompiler(vertexShaderCode: vertexShaderStr, fragmentShaderCode: fragmentShader)
        guard
            let compileResult = try? compiler.complie().get(),
            let programObject = try? compiler.link(compileResult).get()
        else {
            return nil
        }
        
        self.programObject = programObject
        
        "s_baseMap".withCString { pointer in
            baseMapLoc = glGetUniformLocation(programObject, pointer)
        }
        
        "s_lightMap".withCString { pointer in
            lightMapLoc = glGetUniformLocation(programObject, pointer)
        }
        
        baseMapTexId = loadTexture(fileName: "basemap.tga")
        lightMapTexId = loadTexture(fileName: "lightmap.tga")
        
        if baseMapTexId == 0 || lightMapTexId == 0 {
            return nil
        }
        
        glClearColor(1.0, 1.0, 1.0, 0.0)
        
        
    }
    
    func shutDown() {
        glDeleteTextures(1, &baseMapTexId)
        glDeleteTextures(1, &lightMapTexId)
        glDeleteProgram(programObject)
    }
    
    func draw(width: Int, height: Int) {
        
        let vVertices:[GLfloat] = [
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
        
        
        vVertices.withUnsafeBufferPointer({ pointer in
            glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * MemoryLayout<GLfloat>.stride), pointer.baseAddress!)

        })
        
        vVertices.withUnsafeBufferPointer { pointer in
            glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * MemoryLayout<GLfloat>.stride), pointer.baseAddress! + 3)
        }
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), baseMapTexId)
        // Set the base map sampler to texture unit to 0
        glUniform1i(baseMapLoc, 0)
        
        
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), lightMapTexId)
        // Set the light map sampler to texture unit 1
        glUniform1i(lightMapLoc, 1)
        
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_SHORT), &indices)
        
    }
}

//MARK:-

fileprivate extension MutilTextureDemo {
    
    func loadTexture(fileName:String) -> GLuint {
        
        let (data,width,height) = TGA.loadTGA(fileName: fileName)
        guard
            data != nil
        else {
            return 0
        }
        var texId:GLuint = 0
        glGenTextures(1, &texId)
        glBindTexture(GLenum(GL_TEXTURE_2D), texId)
        
        data!.withUnsafeBytes { pointer in
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, width, height, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), pointer.baseAddress!)
        }
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        return texId
    }
    
}

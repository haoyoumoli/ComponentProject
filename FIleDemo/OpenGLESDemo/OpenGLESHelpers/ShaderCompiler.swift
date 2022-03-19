//
//  ShaderManager.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/21.
//

import Foundation
import OpenGLES


///各种UnSafe类型和C语言指针的对应关系:https://blog.csdn.net/u013248706/article/details/112759375


/// 负责编译和链接顶点和片元着色器
class ShaderCompiler {
    
    let vertexShaderCode:String
    
    let fragmentSahderCode:String
    
    init(vertexShaderCode:String, fragmentShaderCode:String) {
        self.vertexShaderCode = vertexShaderCode
        self.fragmentSahderCode = fragmentShaderCode
    }
    
    deinit {
        glReleaseShaderCompiler()
    }
}


//MARK: -  编译
extension ShaderCompiler {
    
    enum CompileError:Error {
        case vertexShaderComplieFail
        case fragmentShaderCompileFail
    }
    
    /// 编译顶点和片元着色器
    /// - Returns: 返回顶点和片元着色器id
    func complie() -> Result<(vertexShader:GLuint,fragmentShader:GLuint),CompileError> {
        
        let vertexShader:GLuint = loadShader(type: GLenum(GL_VERTEX_SHADER), shaderSrc: vertexShaderCode)
        
        if vertexShader == 0 {
            return .failure(.vertexShaderComplieFail)
        }
        
        let fragmentShader:GLuint = loadShader(type: GLenum(GL_FRAGMENT_SHADER), shaderSrc: fragmentSahderCode)
        
        if (fragmentShader == 0) {
            return .failure(.fragmentShaderCompileFail)
        }
        
        return .success((vertexShader: vertexShader, fragmentShader: fragmentShader))
    }
    
    /// 加载shader 代码并编译
    /// - Parameters:
    ///   - type: shader 类型(顶点/片元)
    ///   - shaderSrc: shader 代码
    /// - Returns: 返回shader id, 失败返回 0
    private func loadShader(type:GLenum,shaderSrc:String) -> GLuint {
        let shader:GLuint = glCreateShader(type)
        if shader == 0 {
            return 0
        }
        
        shaderSrc.withCString { pointer in
            var pon:UnsafePointer<GLchar>? = pointer
            
            ///加载shader代码
            glShaderSource(shader, 1, &pon, nil)
        }
        
        ///编译shader
        glCompileShader(shader)
        
        var complited:GLint = -1
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &complited)
        
        if complited == GL_FALSE {
            var infoLen:GLint = 0
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &infoLen)
            if infoLen > 1 {
                let pointer = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(infoLen))
                glGetShaderInfoLog(shader, infoLen, nil, pointer)
                
                let error = String.init(cString: pointer)
                debugPrint(error)
                pointer.deinitialize(count: Int(infoLen))
                pointer.deallocate()
            }
            glDeleteShader(shader)
            return 0
        }
        
        return shader
        
    }
    
}

//MARK: - 链接着色器
extension ShaderCompiler {
    
    enum LinkError:Error {
        case invalidShader
        case creatProgramFailed
        case linkFailed
    }
    
    
    func link(_ shaders:(vertexShader:GLuint,fragmentShader:GLuint)) -> Result<GLuint,LinkError> {
        return link(vertexShader: shaders.vertexShader, fragmentShader: shaders.fragmentShader)
    }
    
    /// 链接着色器
    /// - Returns: 成功范围 glprogrogramid
    func link(vertexShader:GLuint,fragmentShader:GLuint) -> Result<GLuint,LinkError> {
        
        guard vertexShader != 0 && fragmentShader != 0 else {
            return .failure(.invalidShader)
        }
        
        let program = glCreateProgram()
        
        if program == 0 {
            return .failure(.creatProgramFailed)
        }
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glLinkProgram(program)
        
        var linked:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linked)
        if linked == GL_FALSE {
            var infoLen:GLint = 0
            
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infoLen)
            
            if infoLen > 1 {
                let buffer = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(infoLen))
                glGetProgramInfoLog(program, infoLen, nil, buffer)
                
                let errMsg = String(cString: buffer)
                debugPrint(errMsg)
                
                buffer.deinitialize(count: Int(infoLen))
                buffer.deallocate()
            }
            
            glDeleteProgram(program)
            return .failure(.linkFailed)
        }
        
        return .success(program)
    }
    
    
}



//MARK: - 程序二进制代码
extension ShaderCompiler {
    
    /// 检查program 是否链接成功
    /// 链接成功就表示shader的代码没有问题
    /// - Parameter program: program
    /// - Returns: 返回结果
    static func checkProgramLinkSuccess(program:GLuint) -> Bool {
        guard program != 0 else { return false }
        
        var linked:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linked)
        if linked == GL_FALSE { return false }
                
        return true
    }
    
    /// 获取program 编译好的二进制代码,外界可以把它写入磁盘,下次使用时直接使用二进制
    /// 减少在线编译的开销
    /// P 104
    /// - Parameter program: 编译链接好的 program
    /// - Returns: 返回格式和二进制代码
    static func getProgramBinary(program:GLuint) -> (format:GLuint ,data:Data)? {
        
        guard checkProgramLinkSuccess(program: program) else {
            return nil
        }
    
        var binaryFormat:GLuint = 0
        //glGetProgramiv(program, GLenum(GL_PROGRAM_BINARY_FORMATS), &binaryFormat)
        
        var binarySize:GLint = 0
        glGetProgramiv(program, GLenum(GL_PROGRAM_BINARY_LENGTH), &binarySize)
        
        //UnsafeMutableRawPointer  相当于 void*
        let binaryPointer = UnsafeMutableRawPointer.allocate(byteCount: Int(binarySize), alignment: 1)
        defer { binaryPointer.deallocate() }
        glGetProgramBinary(program,GLsizei(binarySize) , nil, &binaryFormat, binaryPointer)
        
        let data = Data.init(bytes: binaryPointer, count: Int(binarySize))
        return (format:binaryFormat,data:data)
    }
    
    
    /// 使用已经链接好的二进制创建program
    /// - Parameters:
    ///   - program: program id (此时没有编译和链接)
    ///   - binary: 链接好的shader 二进制代码
    ///   - format: 二进制代码的格式
    /// - Returns: 返回成功 or 失败
    static func bindLinkedBinaryForProgram(program:GLuint, binary:Data,format:GLuint) -> Bool {
        guard program != 0 else {
            return false
        }
    
        let binaryBytes:GLsizei = GLsizei(binary.count)
        
        binary.withUnsafeBytes { buffer in
            ///program 绑定二进制代码
            glProgramBinary(program, format,buffer.baseAddress ,binaryBytes)
            
        }
        
        ///链接
        glLinkProgram(program)
        
        return checkProgramLinkSuccess(program: program)
    }
}

//MARK: -

#if DEBUG
extension ShaderCompiler {
    
    /// 检查glprogram 是否有效
    /// OPENGL ES 3.0  编程指南 P92
    /// - Parameter program: program id
    static func validateProgram(program:GLuint) -> Bool {
        glValidateProgram(program)
        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_VALIDATE_STATUS), &status);
        return (status == GL_FALSE) ? false : true
    }
}
#endif


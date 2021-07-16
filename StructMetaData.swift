//
//  StructMetaData.swift
//  swift-demo1
//
//  Created by Henry on 2021/7/16.
//

import Foundation

struct StructMetaData{
    var kind : Int32
    var description : UnsafeMutablePointer<StructDescriptor>
}

struct StructDescriptor {
    let flags: Int32
    let parent: Int32
    var name: RelativePointer<CChar>
    var AccessFunctionPtr: RelativePointer<UnsafeRawPointer>
    var Fields: RelativePointer<FieldDescriptor>
    var NumFields: Int32
    var FieldOffsetVectorOffset: Int32
}

struct FieldDescriptor {
    var MangledTypeName: RelativePointer<CChar>
    var Superclass: RelativePointer<CChar>
    var kind: UInt16
    var fieldRecordSize: Int16
    var numFields: Int32
    var fields: FieldRecord //连续的存储空间
}

struct FieldRecord {
    var Flags: Int32
    var MangledTypeName: RelativePointer<CChar>
    var FieldName: RelativePointer<CChar>
}


struct RelativePointer<T> {
    var offset:Int32
    
    mutating public func get() -> UnsafeMutablePointer<T> {
        let offSet = self.offset
        
        return withUnsafePointer(to: &self){ ptr in
            UnsafeMutablePointer(mutating:UnsafeRawPointer(ptr).advanced(by: numericCast(offSet)).assumingMemoryBound(to: T.self))
        }
    }
}
    
class StructMetaTree {
    
    struct Teacher{
        var age = 18
        var name = "henry"
        var height = 1.8
        var hobby = "woman"
    }


    public class func getStructMetaTree() {
        var type = Teacher.self
        //var tttt = tt as Any.Type

        let a = withUnsafeMutablePointer(to: &type) { ptr in
            UnsafeRawPointer(ptr).bindMemory(to: UnsafeMutablePointer<StructMetaData>.self, capacity: 1)
        }
//        let structName = a.pointee.pointee.description.pointee.name.get()
//        let structNameStr = String(cString: structName)

        let b = unsafeBitCast(Teacher.self as Any.Type, to: UnsafeMutablePointer<StructMetaData>.self)
        let structName = b.pointee.description.pointee.name.get()
        let structNameStr = String(cString: structName)
        print("获取结构体名:\(structNameStr)")
        
        let cnt = b.pointee.description.pointee.NumFields
        print("获取结构体属性个数:\(cnt)")
        
        let fieldsPtr = b.pointee.description.pointee.Fields.get()
        for i in 0..<cnt {
            let record = withUnsafePointer(to: &fieldsPtr.pointee.fields) {
                UnsafeMutablePointer(mutating: UnsafeRawPointer($0).assumingMemoryBound(to: FieldRecord.self).advanced(by: numericCast(i)))
            }
            let recordNameStr = String(cString: record.pointee.FieldName.get())
            let manNameStr = String(cString: record.pointee.MangledTypeName.get())
            print("类型名：\(recordNameStr) ----  类型类型：\(manNameStr)")
        }
        
    }
}



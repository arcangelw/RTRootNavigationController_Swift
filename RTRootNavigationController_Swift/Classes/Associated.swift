// Copyright (c) 2022 wuzhe <wuzhezmc@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import ObjectiveC.runtime

/// 是否有关联属性
/// - Parameters:
///   - key: key
///   - object: 关联对象
/// - Returns: 是否存在
func hasAssociatedValue(key: String, object: Any) -> Bool {
    let value = (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.getValue()
    return value != nil
}

/// 获取关联属性
/// - Parameters:
///   - key: key
///   - object: 关联对象
/// - Returns: 关联属性
func associatedValue<T>(key: String, object: Any) -> T? {
    return (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.getValue() as? T
}

/// 获取关联属性
/// - Parameters:
///   - key: key
///   - object: 关联对象
///   - initialValue: 默认属性构造
/// - Returns: 关联属性
func associatedValue<T>(key: String, object: Any, initialValue: @autoclosure () -> T) -> T {
    return associatedValue(
        key: key,
        object: object
    ) ?? setAndReturn(
        initialValue: initialValue(),
        key: key,
        object: object
    )
}

/// 获取关联属性
/// - Parameters:
///   - key: key
///   - object: 关联对象
///   - initialValue: 默认属性构造
/// - Returns: 关联属性
func associatedValue<T>(key: String, object: Any, initialValue: () -> T) -> T {
    return associatedValue(
        key: key,
        object: object
    ) ?? setAndReturn(
        initialValue: initialValue(),
        key: key,
        object: object
    )
}

/// 设置默认返回值
/// - Parameters:
///   - initialValue: 默认值
///   - key: key
///   - object: 关联对象
/// - Returns: 默认值
private func setAndReturn<T>(initialValue: T, key: String, object: Any) -> T {
    set(associatedValue: initialValue, key: key, object: object)
    return initialValue
}

/// 设置关联属性
/// - Parameters:
///   - associatedValue: 关联属性
///   - key: key
///   - object: 关联对象
func set<T>(associatedValue: T?, key: String, object: Any) {
    set(associatedValue: AssociatedValue(associatedValue), key: key, object: object)
}

/// 设置weak关联属性
/// - Parameters:
///   - weakAssociatedValue: 关联属性
///   - key: key
///   - object: 关联对象
func set<T: AnyObject>(weakAssociatedValue: T?, key: String, object: Any) {
    set(associatedValue: AssociatedValue(weak: weakAssociatedValue), key: key, object: object)
}

private extension String {
    /// 获取地址
    var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}

/// 设置管理属性
/// - Parameters:
///   - associatedValue: 关联属性 AssociatedValue包装
///   - key: key
///   - object: 关联对象
private func set(associatedValue: AssociatedValue, key: String, object: Any) {
    objc_setAssociatedObject(object, key.address, associatedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

/// 关联属性包装
private class AssociatedValue {
    /// weak属性
    private weak var weakValue: AnyObject?

    /// strong属性
    private var value: Any?

    /// create a strong
    /// - Parameter value: 关联属性
    init(_ value: Any?) {
        self.value = value
    }

    /// create a weak
    /// - Parameter weak: 关联属性
    init(weak: AnyObject?) {
        weakValue = weak
    }

    /// 获取关联属性
    func getValue() -> Any? {
        return weakValue ?? value
    }
}

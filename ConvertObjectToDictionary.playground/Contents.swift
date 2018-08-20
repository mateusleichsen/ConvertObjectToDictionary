import UIKit

class Person {
    var name:String
    var age:Int
    var birth:Date
    var money:Decimal
    
    init(name:String,age:Int,birth:Date,money:Decimal) {
        self.name = name
        self.age = age
        self.birth = birth
        self.money = money
    }
}

class House {
    var address:String
    var owner:Person
    var residents:[Person]
    
    init() {
        self.address = ""
        self.owner = Person(name: "", age: 0, birth: Date(), money: 0.0)
        self.residents = []
    }
}

class Robot {
    var name:String
    
    init(name:String) {
        self.name = name
    }
}

class TerrainRobot:Robot {
    var numberTires:Int
    init(name:String, numberTires:Int) {
        self.numberTires = numberTires
        super.init(name: name)
    }
}

class TerrainDefenseRobot: TerrainRobot {
    var numberShields:Int
    init(numberShields:Int) {
        self.numberShields = numberShields
        super.init(name: "X1TDR", numberTires: 4)
    }
}

extension Dictionary {
    public static func +=(lhs: inout [Key: Value], rhs: [Key: Value]) { rhs.forEach({ lhs[$0] = $1}) }
}
class Conversor {
    static func convert<T> (object:T) -> [String:Any] {
        var result:[String:Any] = [:]
        let mirrorObject = Mirror(reflecting: object)
        result += Conversor.generateDictionary(from: mirrorObject)
        
        return result
    }
    
    static func convert<T> (object:Array<T>) -> [[String:Any]] {
        var result:[[String:Any]] = []
        for element in object {
            result.append(Conversor.convert(object: element))
        }
        return result
    }
    
    private static func generateDictionary(from mirrorObject: Mirror) -> [String:Any] {
        var result:[String:Any] = [:]
        let superclassMirror = mirrorObject.superclassMirror
        if let _ = superclassMirror?.children {
            result += Conversor.generateDictionary(from: superclassMirror!)
        }
        for case let (label?, value) in mirrorObject.children {
            let grandChildren = Mirror(reflecting: value).children
            if Conversor.hasGranChildren(children: grandChildren) && !isArray(obj: value) {
                result[label] = Conversor.convert(object: value)
            } else if value is Decimal {
                let decimalValue = value as! Decimal
                result[label] = NSDecimalNumber(decimal: decimalValue).floatValue
            } else if isArray(obj: value) {
                let valueArray = value as! [Any]
                result[label] = Conversor.convert(object: valueArray)
            } else {
                result[label] = value
            }
        }
        
        return result
    }
    
    private static func hasGranChildren(children:AnyCollection<Mirror.Child>) -> Bool {
        if let i0 = children.index(children.startIndex, offsetBy: 1, limitedBy: children.endIndex), i0 != children.endIndex {
            return true
        } else {
            return false
        }
    }
    
    private static func isArray(obj: Any) -> Bool {
        return obj is Array<Any>
    }
}

//tests
let person = Person(name: "John", age: 34, birth: Date(), money: 5.60)
let personDictionary = Conversor.convert(object: person)

let house = House()
house.owner = Person(name: "Amy", age: 23, birth: Date(), money: 23.50)
house.address = "not far"
house.residents = [person, Person(name: "Andy", age: 28, birth: Date(), money: 300.00), house.owner]
let houseDictionary = Conversor.convert(object: house)

func readDictionary(dictionary:[String:Any]) {
    for element in dictionary {
        print("\(element.key): \(element.value)")
    }
}

readDictionary(dictionary: houseDictionary)
readDictionary(dictionary: personDictionary)

//subclass test
let robot = Robot(name: "X1R")
let terrainRobot = TerrainRobot(name: "X1TR", numberTires: 1)
let terrainDefenseRobot = TerrainDefenseRobot(numberShields: 5)

let robotDictionary = Conversor.convert(object: robot)
let terrainRobotDictionary = Conversor.convert(object: terrainRobot)
let terrainDefenseRobotDictionary = Conversor.convert(object: terrainDefenseRobot)
print(terrainDefenseRobotDictionary)


import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Float "mo:base/Float";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";


actor Tracker{

  type Transaction = {
        topic:Text;
        id:Text;
        date:Text;
        category:Text;
        secondPerson:Text;
        amount:Float;
    };
    type Investment = {
        name:Text;
        id:Text;
        date:Text;
        amount:Float;
        rate:Nat;
    };
    type User={
      name:Text;
      email:Text;
      phone:Nat;
      pass:Text;
      investments:[Investment];
      transactions:[Transaction];
    };
    var map = HashMap.HashMap<Text, User>(0, Text.equal, Text.hash);
    stable var userList:[(Text,User)] = [];

    system func preupgrade() {
        userList := Iter.toArray(map.entries());
    };

    system func postupgrade() {
        map := HashMap.fromIter<Text, User>(userList.vals(), 1, Text.equal, Text.hash);
        userList := [];
    };
  
    public func createUser(name:Text,email:Text,phone:Nat,pass:Text) : async User {
      let user:User={
        name=name;
        email=email;
        phone=phone;
        pass=pass;
        investments=[];
        transactions=[];
      };
      map.put(email,user); 
      
      return user;
    };
    public query func getUser(email:Text):async User{
      var user:User={
        name="";
        email="";
        phone=1;pass="";
        investments=[];
        transactions=[];
      };

      let userRes=switch(map.get(email)){
        case (null) return user;
        case (?User) return User;

      };
      return userRes;
    };
    public func upgradeUser(name:Text,email:Text,phone:Nat,pass:Text,transactions:[ Transaction],investments:[ Investment]):async User{
      let user:User={
        name=name;
        email=email;
        phone=phone;
        pass=pass;
        investments=investments;
        transactions=transactions;
      };
      let res=map.replace(email,user);
      return user;
    } 

}
    



//PREVIOUS CODE-->
// import Nat "mo:base/Nat";
// import Text "mo:base/Text";
// import Float "mo:base/Float";
// import List "mo:base/List";
// import HashMap "mo:base/HashMap";
// import Iter "mo:base/Iter";


// actor Tracker{

//   type Transaction = {
//         topic:Text;
//         id:Text;
//         date:Text;
//         category:Text;
//         secondPerson:Text;
//         amount:Float;
//     };
//     type Investment = {
//         name:Text;
//         id:Text;
//         date:Text;
//         amount:Float;
//         rate:Nat;
//     };
//     type User={
//       name:Text;
//       email:Text;
//       phone:Nat;
//       pass:Text;
//       investments:List.List<Investment>;
//       transactions:List.List<Transaction>;
//     };
//     var map = HashMap.HashMap<Text, User>(0, Text.equal, Text.hash);
//     stable var userList:[(Text,User)] = [];

//     system func preupgrade() {
//         userList := Iter.toArray(map.entries());
//     };

//     system func postupgrade() {
//         map := HashMap.fromIter<Text, User>(userList.vals(), 1, Text.equal, Text.hash);
//         userList := [];
//     };
  
//     public func createUser(name:Text,email:Text,phone:Nat,pass:Text) : async Nat {
//       let user:User={
//         name=name;
//         email=email;
//         phone=phone;
//         pass=pass;
//         investments=List.nil<Investment>();
//         transactions=List.nil<Transaction>();
//       };
//       map.put(email,user); 
      
//       return map.size();
//     };
//     public query func getUser(email:Text):async User{
//       var user:User={name="";email="";phone=1;pass="";investments=List.nil<Investment>();
//       transactions=List.nil<Transaction>();};

//       let userRes=switch(map.get(email)){
//         case (null) return user;
//         case (?User) return User;

//       };
//       return userRes;
//     };
//     //public func 

// }
    
//dfx identity new lpu
//dfx identity use lpu
//dfx identity list
//dfx identity get-principal
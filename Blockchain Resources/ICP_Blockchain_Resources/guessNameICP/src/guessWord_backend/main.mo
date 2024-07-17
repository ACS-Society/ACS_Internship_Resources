import Text "mo:base/Text";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";


actor GuessGame{
  type User={
    name:Text;
    email:Text;
    pass:Text;
    wins:Int;
    loses:Int;
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
  
  public func createUser(name:Text,email:Text,pass:Text):async User{
    let user:User={
      name=name;
      email=email;
      pass=pass;
      wins=0;
      loses=0;
    };
    map.put(email,user);
    return user;
  };
  public func upgradeScore(name:Text,pass:Text,email:Text,win:Int,lose:Int):async User{
    var user:User={
      name=name;
      email=email;
      pass=pass;
      wins=win;
      loses=lose;
    }; 
    let res=map.replace(email,user);
    return user;
  };
  public query func getUser(email:Text):async User{
    var user:User={
      name="";
      email="";
      pass="";
      wins=0;
      loses=0;
    };
    let userRes:User=switch(map.get(email)){
        case (null) return user;
        case (?User) return User;
      };
    return userRes;
  }
}
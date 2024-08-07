import Array "mo:base/Array";
import Account "Lib/Account";
import Blob  "mo:base/Blob";
import Bucket "Lib/Bucket";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Prim "mo:⛔";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import TrieSet "mo:base/TrieSet";
import Types "Lib/Types";

actor iCAN{

    type Management = Types.Management;
    type Memo = Types.Memo;
    type AccountIdentifier = Types.AccountIdentifier;
    type SubAccount = Types.SubAccount;
    type CycleInterface = Types.CycleInterface;
    type Ledger = Types.Ledger;
    type CMC = Types.CMC;
    type TransformArgs = Types.TransformArgs;
    type HubInterface = Types.HubInterface;
    type Error = Types.Error;
    type wasm_module = Types.wasm_module;

    let CYCLE_MINTING_CANISTER = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
    let cmc : CMC = actor("rkp4c-7iaaa-aaaaa-aaaca-cai");
    let ledger : Ledger = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");
    let management : Management = actor("aaaaa-aa");
    let TOP_UP_CANISTER_MEMO = 0x50555054 : Nat64;
    let CREATE_CANISTER_MEMO = 0x41455243 : Nat64;

    stable var administrators : TrieSet.Set<Principal> = TrieSet.empty<Principal>();
    stable var cycle_wasm : [Nat8] = [];
    stable var hub_wasm : [Nat8] = [];
    stable var bucket_upgrade_params : (Nat, [(Nat,(Nat64, Nat))]) = (0, []);
    stable var log_index = 0;
    stable var entries : [(Principal, [(Text, Principal)])] = [];

    var logs = Bucket.Bucket(true);
    var hubs : TrieMap.TrieMap<Principal, [(Text, Principal)]> = TrieMap.fromEntries<Principal, [(Text, Principal)]>(entries.vals(), Principal.equal, Principal.hash);

    public query({caller}) func getHub() : async [(Text, Principal)]{
        switch(hubs.get(caller)){
            case null { [] };
            case(?b){ b }
        }
    };

    public query({caller}) func getLog() : async [(Nat, Text)]{
        assert(TrieSet.mem<Principal>(administrators, caller, Principal.hash(caller), Principal.equal));
        let res = Array.init<(Nat, Text)>(log_index, (0, ""));
        var index = 0;
        for(l in res.vals()){
            res[index] := logs.get(index);
            index += 1;
        };
        Array.freeze<(Nat, Text)>(res)
    };

    public query func getWasms() : async ([Nat8], [Nat8]){
        (hub_wasm, cycle_wasm)
    };

    public query func getAdministrators() : async [Principal]{ TrieSet.toArray<Principal>(administrators) };

    public shared({caller}) func uploadCycleWasm(_wasm : [Nat8]) : async Text{
        assert(TrieSet.mem<Principal>(administrators, caller, Principal.hash(caller), Principal.equal));
        cycle_wasm := _wasm;
        ignore _addLog("Upload Cycle Wasm Successfully, Caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30));
        "successfully"
    };

    public shared({caller}) func uploadHubWasm(_wasm : [Nat8]) : async Text{
        assert(TrieSet.mem<Principal>(administrators, caller, Principal.hash(caller), Principal.equal));
        hub_wasm := _wasm;
        ignore _addLog("Upload Hub Wasm Successfully, Caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30));
        "successfully"
    };

    public shared({caller}) func changeAdministrator(nas : [Principal]): async Text{
        assert(TrieSet.mem<Principal>(administrators, caller, Principal.hash(caller), Principal.equal));
        administrators := TrieSet.fromArray<Principal>(nas, Principal.hash, Principal.equal);
        "successfully"
    };

    public shared({caller}) func createHub(name : Text, amount : Nat64) : async Result.Result<Principal, Error>{
        assert(amount > 2_000_000);
        let subaccount = Blob.fromArray(Account.principalToSubAccount(caller));
        let ican_cycle_subaccount = Blob.fromArray(Account.principalToSubAccount(Principal.fromActor(iCAN)));
        let ican_cycle_ai = Account.accountIdentifier(CYCLE_MINTING_CANISTER, ican_cycle_subaccount);
        ignore topUpSelf(caller);
        ignore _addLog("Transfer Service Fee Successfully, caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30));
        switch(await ledger.transfer({
            to = ican_cycle_ai;
            fee = { e8s = 10_000 };
            memo = CREATE_CANISTER_MEMO;
            from_subaccount = ?subaccount;
            amount = { e8s = amount - 1_010_000 };
            created_at_time = null;
        })){
            case(#Ok(block_height)){
                ignore _addLog("Transfer Top Up Fee Successfully, Caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30));
                switch(await cmc.notify_create_canister({
                   block_index = block_height;
                   controller = Principal.fromActor(iCAN);
                })){
                    case(#Ok(id)){
                        let h : HubInterface = actor(Principal.toText(id));
                        _addHub(caller, (name, id));
                        await management.install_code({
                            arg = [];
                            wasm_module = hub_wasm;
                            mode = #install;
                            canister_id = id;
                        });
                        ignore h.init(caller, cycle_wasm);
                        ignore management.update_settings({
                            canister_id = id;
                            settings = {
                                freezing_threshold = null;
                                controllers = ?[caller, id];
                                memory_allocation = null;
                                compute_allocation = null;
                            }
                        });
                        ignore _addLog("Create Canister Successfully, caller : " # debug_show(caller) # "Time : "#debug_show(Prim.time() >> 30) # "canister id : " # debug_show(id));
                        #ok(id)
                    };
                    case(#Err(e)){
                        #err(#Create_Canister_Failed(_addLog("Notify Create Canister Failed, caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30)#", Error : "#debug_show(e)#" Args : " # debug_show(amount))));
                    }
                }
            };
            case(#Err(e)){
                #err(#Create_Canister_Failed(_addLog("Transfer Create Canister Fee Failed, caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30)#", Error : "#debug_show(e)#" Args : " # debug_show(amount))))
            }
        }
    };

    // public shared({caller}) func addHub(
    //     name : Text,
    //     hub_id : Principal
    // ) : async Text{ 
    //     assert(TrieSet.mem<Principal>(administrators, caller, Principal.hash(caller), Principal.equal));
    //     switch(hubs.get(caller)){
    //         case null { hubs.put(caller, [(name, hub_id)]) };
    //         case(?ps){ hubs.put(caller, Array.append(ps, [(name, hub_id)])) }
    //     };
    //     "success"
    // };

    public shared({caller}) func changeHubInfo(
        name : Text,
        hub_id : Principal
    ) : async Text{ 
        ignore _changeHubInfo(caller,(name,hub_id));
        "success"
    };

    public shared({caller}) func deleteHub(
        hub_id : Principal, 
        to_canister_id : Principal
    ) : async Result.Result<(), Error>{
        var flag  = 0;
        switch(hubs.get(caller)){
            case(null) {return #err(#Nonexistent_Caller)};
            case(?b) {
                for (x in b.vals()){
                    if (x.1 == hub_id){
                        flag := 1;
                    };
                };
                if(flag == 0){return #err(#Invalid_Caller)};
            }
        };
        if((await management.canister_status({ canister_id = hub_id })).cycles > 10_000_000_000) {
            await management.start_canister({ canister_id = hub_id });
            await management.install_code({
                arg = [];
                wasm_module = cycle_wasm;
                mode = #reinstall;
                canister_id = hub_id;
            });
            let from : CycleInterface = actor(Principal.toText(hub_id));
            await from.withdraw_cycles({ canister_id = to_canister_id});
        };
        await management.stop_canister({ canister_id = hub_id });
        ignore management.delete_canister({ canister_id = hub_id });
        switch(_delHub(caller,hub_id)){
            case(#Err(_)){return #err(#Delete_Hub_Failed)};
            case(#Ok){ };
        };
        #ok(())
    };

    public shared({caller}) func transformIcp(
        args : TransformArgs
    ) : async Result.Result<(), Error>{
        assert(args.icp_amount > 1_010_000);
        ignore topUpSelf(caller);
        let subaccount = Blob.fromArray(Account.principalToSubAccount(caller));
        let cycle_subaccount = Blob.fromArray(Account.principalToSubAccount(args.to_canister_id));
        let cycle_ai = Account.accountIdentifier(CYCLE_MINTING_CANISTER, cycle_subaccount);
        switch(await ledger.transfer({
            to = cycle_ai;
            fee = { e8s = 10_000 };
            memo = TOP_UP_CANISTER_MEMO;
            from_subaccount = ?subaccount;
            amount = { e8s = args.icp_amount - 1_010_000 };
            created_at_time = null;
        })){
            case(#Err(e)){
                #err(#Ledger_Transfer_Failed(_addLog("Transfer Service Fee Failed, caller : "#debug_show(caller)#" , Time : "#debug_show(Prim.time() >> 30)#" Error : " # debug_show(e) #" Args : " # debug_show(args))))
            };
            case(#Ok(height)){
                ignore cmc.notify_top_up(
                    {
                        block_index = height;
                        canister_id = args.to_canister_id;
                    }
                );
                #ok(())
            }
        }
    };

    public shared({caller}) func topUpSelf(_caller : Principal) : async (){
        assert(caller == Principal.fromActor(iCAN));
        let subaccount = Blob.fromArray(Account.principalToSubAccount(_caller));
        let cycle_subaccount = Blob.fromArray(Account.principalToSubAccount(Principal.fromActor(iCAN)));
        let cycle_ai = Account.accountIdentifier(CYCLE_MINTING_CANISTER, cycle_subaccount);
        switch(await ledger.transfer({
            to = cycle_ai;
            fee = { e8s = 10_000 };
            memo = TOP_UP_CANISTER_MEMO;
            from_subaccount = ?subaccount;
            amount = { e8s = 990_000 };
            created_at_time = null;
        })){
            case(#Err(e)){
                ignore _addLog("Top Up Self Failed, caller : "#debug_show(_caller)#" , Time : "#debug_show(Prim.time() >> 30)#" Error : " # debug_show(e))
            };
            case(#Ok(height)){
                ignore cmc.notify_top_up(
                    {
                      block_index = height;
                      canister_id = Principal.fromActor(iCAN);
                    }
                );
                ignore _addLog("Top Up Self Successfully, caller : "#debug_show(_caller)#" , Time : "#debug_show(Prim.time() >> 30))
            }
        }
    };

    public shared({caller}) func clearLog() : async (){
        assert(TrieSet.mem<Principal>(administrators, caller, Principal.hash(caller), Principal.equal));
        log_index := 0;
        logs.clear();
    };

    private func _addHub(owner : Principal, args : (Text, Principal)){
        switch(hubs.get(owner)){
            case(null) { hubs.put(owner,[args]) };
            case(?b){
                let p = Array.append(b, [args]);
                hubs.put(owner, p);
            }
        };
    };

    private func _delHub(owner : Principal, args : Principal) : Result.Result<(), Text>{
        switch(hubs.get(owner)){
            case(null) { #err("can not find the owner") };
            case(?b){
                if(b.size() > 1){
                    let res = Array.init<(Text, Principal)>(b.size() - 1, ("", Principal.fromActor(iCAN)));
                    var _index = 0;
                    for(p in b.vals()){
                        if(p.1 != args){
                            res[_index] := p;
                            _index += 1;
                        };
                    };
                    hubs.put(owner, Array.freeze<(Text, Principal)>(res));
                }else{
                    hubs.delete(owner);
                };
                #ok(())
            }
        };
    };

    private func _changeHubInfo(owner : Principal, args : (Text, Principal)) : Result.Result<(), Text>{
        switch(hubs.get(owner)){
            case(null) { #err("can not find the owner") };
            case(?b){
                let res = Array.init<(Text, Principal)>(b.size(), ("", Principal.fromActor(iCAN)));
                var _index = 0;
                for(p in b.vals()){
                    if(p.1 != args.1){
                        res[_index] := p;
                    }else{
                        res[_index] := args;
                    };
                    _index += 1;
                };
                hubs.put(owner, Array.freeze<(Text, Principal)>(res));
                #ok(())
            }
        };
    };
    // return log id
    private func _addLog(log : Text) : Nat{
        let id = log_index;
        ignore logs.put(id, log);
        log_index += 1;
        id
    };

    system func preupgrade(){
        entries := Iter.toArray(hubs.entries());
        bucket_upgrade_params := logs.preupgrade();
    };

    system func postupgrade(){
        entries := [];
        logs.postupgrade(bucket_upgrade_params);
        bucket_upgrade_params := (0, []);
    };

    public func wallet_receive() : async (){
        ignore Cycles.accept(Cycles.available())
    };

};

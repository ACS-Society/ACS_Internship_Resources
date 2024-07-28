from pyteal import *
from pyteal.ast.bytes import Bytes
from pyteal_helpers import program

def approval():
    seller_address = Bytes("seller")
    end_time_value = Bytes("end")
    asset_id = Bytes("asset_id")
    min_bid_value = Bytes("min_bid")
    lead_bid_amount_value = Bytes("bid_amount")
    lead_bid_account_value = Bytes("bid_account")

# arguement [2] is time delay
    global_end_time = Global.latest_timestamp() + Btoi(Txn.application_args[2])

    @Subroutine(TealType.none)
    def closeassetTo(assetID: Expr, account: Expr) -> Expr:
        asset_holding = AssetHolding.balance(
            Global.current_application_address(), assetID
        )
        return Seq(
            asset_holding,
            If(asset_holding.hasValue()).Then(
                Seq(
                    InnerTxnBuilder.Begin(),
                    InnerTxnBuilder.SetFields(
                        {
                            TxnField.type_enum: TxnType.AssetTransfer,
                            TxnField.xfer_asset: assetID,
                            TxnField.asset_close_to: account,
                        }
                    ),
                    InnerTxnBuilder.Submit(),
                )
            ),
        )

    @Subroutine(TealType.none)
    def transferLastMaxBidder(prevLeadBidder: Expr, prevLeadBidAmount: Expr) -> Expr:
        return Seq(
            InnerTxnBuilder.Begin(),
            InnerTxnBuilder.SetFields(
                {
                    TxnField.type_enum: TxnType.Payment,
                    TxnField.amount: prevLeadBidAmount ,
                    TxnField.receiver: prevLeadBidder,
                }
            ),
            InnerTxnBuilder.Submit(),
        )

    @Subroutine(TealType.none)
    def TransferContractFunds(account: Expr) -> Expr:
        return If(Balance(Global.current_application_address()) != Int(0)).Then(
            Seq(
                InnerTxnBuilder.Begin(),
                InnerTxnBuilder.SetFields(
                    {
                        TxnField.type_enum: TxnType.Payment,
                        TxnField.close_remainder_to: account,
                    }
                ),
                InnerTxnBuilder.Submit(),
            )
        )

    on_create = Seq(
        App.globalPut(seller_address, Txn.sender()),
        App.globalPut(asset_id, Btoi(Txn.application_args[1])),
        App.globalPut(end_time_value, global_end_time),
        App.globalPut(min_bid_value, Btoi(Txn.application_args[3])),
        App.globalPut(lead_bid_account_value, Global.zero_address()),
        InnerTxnBuilder.Begin(),
        InnerTxnBuilder.SetFields(
            {
                TxnField.type_enum: TxnType.AssetTransfer,
                TxnField.xfer_asset: App.globalGet(asset_id),
                TxnField.asset_receiver: Global.current_application_address(),
            }
        ),
        InnerTxnBuilder.Submit(),
        Approve(),
    )

    # takes care latest transaction validity using micro transation  
    on_bid_txn_index = Txn.group_index() - Int(1)
    on_bid_asset_holding = AssetHolding.balance(
        Global.current_application_address(), App.globalGet(asset_id)
    )
    on_bid = Seq(
        on_bid_asset_holding,
        Assert(
            And(
                on_bid_asset_holding.hasValue(),
                on_bid_asset_holding.value() > Int(0),
                Global.latest_timestamp() < App.globalGet(end_time_value),
                Gtxn[on_bid_txn_index].type_enum() == TxnType.Payment,
                Gtxn[on_bid_txn_index].sender() == Txn.sender(),
                Gtxn[on_bid_txn_index].receiver()
                == Global.current_application_address(),
            )
        ),
        If(
            Gtxn[on_bid_txn_index].amount()
            >= App.globalGet(min_bid_value)
        ).Then(
            Seq(
                If(App.globalGet(lead_bid_account_value) != Global.zero_address()).Then(
                    transferLastMaxBidder(
                        App.globalGet(lead_bid_account_value),
                        App.globalGet(lead_bid_amount_value),
                    )
                ),
                App.globalPut(lead_bid_amount_value, Gtxn[on_bid_txn_index].amount()),
                App.globalPut(lead_bid_account_value, Gtxn[on_bid_txn_index].sender()),
                Approve(),
            )
        ),
        Reject(),
    )

    close_bid =Seq(
        If(Txn.sender()==App.globalGet(seller_address)).Then(
            Seq(
                If(Txn.sender()==App.globalGet(seller_address)).Then(
                    Seq(
                        Assert(
                            Or(
                                Txn.sender() == App.globalGet(seller_address),
                                Txn.sender() == Global.creator_address(),
                            )
                        ),
                        closeassetTo(App.globalGet(asset_id), App.globalGet(seller_address)),
                        TransferContractFunds(App.globalGet(seller_address)),
                        Approve(),
                    )
                ),
                If(App.globalGet(end_time_value) <= Global.latest_timestamp()).Then(
                    Seq(
                        If(App.globalGet(lead_bid_account_value) != Global.zero_address())
                        .Then(
                            If(
                                App.globalGet(lead_bid_account_value) != Global.zero_address()
                            )
                            .Then(
                                closeassetTo(
                                    App.globalGet(asset_id),
                                    App.globalGet(lead_bid_account_value),
                                )
                            )
                            .Else(
                                Seq(
                                    closeassetTo(
                                        App.globalGet(asset_id), App.globalGet(seller_address)
                                    ),
                                    transferLastMaxBidder(
                                        App.globalGet(lead_bid_account_value),
                                        App.globalGet(lead_bid_amount_value),
                                    ),
                                )
                            )
                        ) 
                        .Else(
                            closeassetTo(App.globalGet(asset_id), App.globalGet(seller_address))
                        ),
                        TransferContractFunds(App.globalGet(seller_address)),
                        Approve(),
                    )
                )
            ),
        ),
        Reject(),
    )
    
    return program.event(
        init = Approve(), 
        opt_in = Seq(
            Approve(), 
        ),
        no_op=Seq(
            Cond(
                [Txn.application_args[0]== Bytes("create"), on_create],
                [Txn.application_args[0]== Bytes("bid"), on_bid],
                [Txn.application_args[0]== Bytes("kill"), close_bid],
            ),
            Reject(),
        ),
    )


def clear(): 
    return Approve()
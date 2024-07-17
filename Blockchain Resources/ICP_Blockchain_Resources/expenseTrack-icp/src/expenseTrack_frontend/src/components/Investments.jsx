import React from "react";
import TopNavOut from "./TopNavOut";
import { useNavigate } from "react-router-dom";
import SideMenu from "./SideMenu";
import axios from "axios";
import { expenseTrack_backend } from "../../../declarations/expenseTrack_backend/index";

const Investments = ({ setUser, user, setLogin }) => {
  const nav = useNavigate();

  const addinvestment = async () => {
    const amount = document.getElementById("amount").value;
    const title = document.getElementById("title").value;
    const date = document.getElementById("date").value;
    const rate = document.getElementById("rate").value;

    let inv = user.investments;
    inv.unshift({
      id: user.name,
      name: title.toString(),
      date: date.toString(),
      amount: parseFloat(amount),
      rate: parseInt(rate),
    });
    const userNew=await expenseTrack_backend.upgradeUser(user.name,user.email,user.phone,user.pass,user.transactions,inv)
    console.log(userNew)
    setUser(userNew)
    alert("investment added")




    // try {
    //   await axios
    //     .patch("https://expense-backend-production-1893.up.railway.app/user", {
    //       id: user._id,
    //       transactions: user.transactions,
    //       investments: inv,
    //     })
    //     .then((res) => {
    //       console.log(res.data);
    //       alert("investment added!!!");
    //     });
    // } catch (err) {
    //   console.log(err);
    // }
    // await axios
    //   .get("https://expense-backend-production-1893.up.railway.app/user", {
    //     params: { email: user.email },
    //   })
    //   .then((res) => {
    //     setUser(res.data);
    //   });
  };
  return (
    <>
      <TopNavOut setLogin={setLogin} nav={nav} />
      <div className="transac">
        <SideMenu nav={nav} />
        <div className="t-list">
          <h1>Investments </h1>
          <div
            className="text-card sec"
            style={{ width: "30vw", marginBottom: "40px" }}
          >
            <div className="inpCalc">
              Amount : <input type="number" id="amount" />
            </div>
            <div className="inpCalc">
              Title: <input type="text" id="title" />
            </div>
            <div className="inpCalc">
              Date : <input type="date" id="date" />
            </div>
            <div className="inpCalc">
              Rate: <input type="number" id="rate" />
            </div>
            <button onClick={addinvestment}>Add Investment</button>
          </div>
          {/* <form>
            <select>
              <option value="jan">January</option>
              <option value="jan">January</option>
              <option value="jan">January</option>
              <option value="jan">January</option>
            </select>
            <input type="number" placeholder="year" />
          </form> */}
          <div className="transac-cont-head">
            <h2>Title</h2>
            <h2>Amount</h2>
            <h2>Rate(%)</h2>
          </div>
          {user.investments.map((i) => {
            return (
              <div className="transac-cont">
                <p>{i.name}</p>
                <p>Rs.{i.amount}</p>
                <p>{parseInt(i.rate)}</p>
              </div>
            );
          })}
        </div>
      </div>
    </>
  );
};

export default Investments;

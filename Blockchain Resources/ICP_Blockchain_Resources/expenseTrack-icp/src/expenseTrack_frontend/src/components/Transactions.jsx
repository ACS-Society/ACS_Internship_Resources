import React from "react";
import TopNavOut from "./TopNavOut";
import { useNavigate } from "react-router-dom";
import SideMenu from "./SideMenu";
import axios from "axios";
import { expenseTrack_backend } from "../../../declarations/expenseTrack_backend/index";

const Transactions = ({ setUser, user, setLogin }) => {
  const nav = useNavigate();

  const addtransaction = async () => {
    const amount = document.getElementById("amount").value;
    const title = document.getElementById("title").value;
    const date = document.getElementById("date").value;
    const category = document.getElementById("category").value;
    const second = document.getElementById("second").value;

    let trs = user.transactions;
    trs.unshift({
      id: user.name,
      date: date.toString(),
      topic: title.toString(),
      amount: parseFloat(amount),
      category: category.toString(),
      secondPerson: second.toString(),
    });
    const userNew=await expenseTrack_backend.upgradeUser(user.name,user.email,user.phone,user.pass,trs,user.investments)
    console.log(userNew)
    setUser(userNew)
    alert("transaction added")

    // try {
    //   await axios
    //     .patch("https://expense-backend-production-1893.up.railway.app/user", {
    //       id: user._id,
    //       transactions: trs,
    //       investments: user.investments,
    //     })
    //     .then((res) => {
    //       console.log(res.data);
    //       alert("transaction added!!!");
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
    // console.log(user);
    // let d = new Date(user.transactions.date);
    // console.log(d.getMonth());
  };

  return (
    <>
      <TopNavOut setLogin={setLogin} nav={nav} />
      <div className="transac">
        <SideMenu nav={nav} />
        <div className="t-list">
          <h1>Transactions </h1>
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
              Category:
              <select id="category">
                <option value="Essentials">Essentials</option>
                <option value="Gifts">Gifts</option>
                <option value="Entertainment">Entertainment</option>
              </select>
            </div>
            <div className="inpCalc">
              To: <input type="text" id="second" />
            </div>
            <button onClick={addtransaction}>Add Transaction</button>
          </div>
          <div className="transac-cont-head">
            <h2>Title</h2>
            <h2>Amount</h2>
            <h2>Category</h2>
            <h2>To</h2>
          </div>
          {user.transactions.map((t) => {
            return (
              <div className="transac-cont">
                <p>{t.topic}</p>
                <p>Rs.{t.amount}</p>
                <p>{t.category}</p>
                <p>{t.secondPerson}</p>
              </div>
            );
          })}
        </div>
      </div>
    </>
  );
};

export default Transactions;

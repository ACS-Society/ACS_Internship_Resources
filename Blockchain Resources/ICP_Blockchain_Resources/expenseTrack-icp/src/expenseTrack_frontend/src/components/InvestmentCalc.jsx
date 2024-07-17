import React, { useState } from "react";
import TopNavOut from "./TopNavOut";
import { useNavigate } from "react-router-dom";
import SideMenu from "./SideMenu";

const InvestmentCalc = ({ setLogin }) => {
  const [interest, setInterest] = useState(0);
  const [amount, setAmount] = useState(0);
  const nav = useNavigate();

  const calc = () => {
    const amount = document.getElementById("amount").value;
    const time = document.getElementById("time").value;
    const rate = document.getElementById("rate").value;
    let i = (amount * time * rate) / 100;
    setAmount(amount);
    setInterest(i);
  };

  return (
    <>
      <TopNavOut setLogin={setLogin} nav={nav} />
      <div className="transac">
        <SideMenu nav={nav} />
        <div className="sec">
          <div className="text-card" style={{ marginTop: "10vh" }}>
            <h1> Investment Calculator </h1>
            <div className="inpCalc">
              Amount : <input type="number" id="amount" />
            </div>
            <div className="inpCalc">
              Time Period : <input type="number" id="time" />
            </div>
            <div className="inpCalc">
              Expected Return Rate : <input type="number" id="rate" />
            </div>
            <button onClick={calc}>Calculate</button>
            <p className="inp-txt">Expected interest return : {interest}</p>
            {/* <p>Amount after specified time period : {amount + interest}</p> */}
          </div>
        </div>
      </div>
    </>
  );
};

export default InvestmentCalc;

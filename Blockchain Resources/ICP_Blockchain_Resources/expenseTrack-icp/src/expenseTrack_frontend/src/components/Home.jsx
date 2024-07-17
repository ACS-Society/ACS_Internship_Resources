import React from "react";
import { useNavigate } from "react-router-dom";
import TopNav from "./TopNav";

const Home = () => {
  const nav = useNavigate();
  return (
    <>
      <TopNav nav={nav} />
      <div className="homePage">
        <div>
          <h1>
            Empower Your Finances,
            <br />
            Effortlessly Managed.
          </h1>
          <p>
            Our vision is to create a society with individuals
            <br />
            who are more financial literate an in order to achieve it
            <br />
            we present to you <em>Expense Manager</em>
          </p>
          <button onClick={() => nav("/register")}>Join Us</button>
        </div>
      </div>
    </>
  );
};

export default Home;

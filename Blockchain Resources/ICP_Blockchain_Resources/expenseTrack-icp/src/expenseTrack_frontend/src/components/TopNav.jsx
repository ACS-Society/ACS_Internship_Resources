import React from "react";

const TopNav = ({ nav }) => {
  return (
    <div className="top-nav">
      <div className="logo-cont">
        <div>
          <img src="expenseLogo.PNG" alt="menu" />
          <h1>Expense Manager</h1>
        </div>
        <button onClick={() => nav("/login")}>Sign In</button>
      </div>
    </div>
  );
};

export default TopNav;

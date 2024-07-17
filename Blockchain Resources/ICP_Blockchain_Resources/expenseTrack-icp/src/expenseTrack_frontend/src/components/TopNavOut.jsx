import React from "react";

const TopNavOut = ({ nav, setLogin }) => {
  return (
    <div className="top-nav">
      <div className="logo-cont">
        <div>
          <img src="expenseLogo.png" alt="menu" />
          <h1>Expense Manager</h1>
        </div>
        <button
          onClick={() => {
            nav("/");
            setLogin(false);
          }}
        >
          Sign Out
        </button>
      </div>
    </div>
  );
};

export default TopNavOut;

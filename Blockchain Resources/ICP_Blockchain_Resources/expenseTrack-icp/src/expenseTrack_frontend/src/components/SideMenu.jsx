import React from "react";

const SideMenu = ({ nav }) => {
  return (
    <div className="nav">
      <h1 onClick={() => nav("/")}>Dashboard</h1>
      <h1 onClick={() => nav("/transactions")}>Transactions</h1>
      <h1 onClick={() => nav("/calc")}>Investment Calculator</h1>
      <h1 onClick={() => nav("/investments")}>Investments</h1>
    </div>
  );
};

export default SideMenu;

import React from "react";
import TopNavOut from "./TopNavOut";
import { useNavigate } from "react-router-dom";
import SideMenu from "./SideMenu";
import Barchart from "./BarChart";
import Piechart from "./PieChart";

const Dashboard = ({ user, data, setLogin }) => {
  const nav = useNavigate();
  // var rev = 0;
  // var ex = 0;
  // data.transaction_month.forEach((month) => {
  //   rev += month.revenue;
  //   ex += month.investment;
  // });
  return (
    <>
      <TopNavOut setLogin={setLogin} nav={nav} />
      <div className="transac">
        <SideMenu nav={nav} />
        <div className="sec">
          <div className="details">
            <div className="text-card">
              <h4>User Details</h4>
              <p>Name : {user.name}</p>
              <p>Email : {user.email}</p>
              <p>Contact number : {parseInt(user.phone)}</p>
            </div>
            <div className="text-card">
              <h4>Total Investents : </h4>

              <p className="num">{user.investments.length}</p>
            </div>
            <div className="text-card">
              <h4>Transaction records :</h4>

              <p className="num"> {user.transactions.length}</p>
            </div>
          </div>
          <div className="stats">
            <div className="chart-con">
              <h1>Ranges of Investment/Expense : </h1>
              <Barchart user={user} />
            </div>

            <div className="chart-con">
              <h1>Types of Expenses: </h1>
              <Piechart user={user} />
            </div>
          </div>
          {/* <p>{data}</p> */}
        </div>
      </div>
    </>
  );
};

export default Dashboard;

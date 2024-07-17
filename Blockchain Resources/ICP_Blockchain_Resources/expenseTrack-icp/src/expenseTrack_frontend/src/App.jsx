import React from 'react'
import { useState } from "react";
import "./App.css";
import Home from "./components/Home";
import Transactions from "./components/Transactions";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Dashboard from "./components/Dashboard";
import Investments from "./components/Investments";
import InvestmentCalc from "./components/InvestmentCalc";
import Login from "./components/Login";
import Register from "./components/Register";
import admins from "./data";

function App() {
  const [login, setLogin] = useState(false);
  const [user, setUser] = useState({});
  return (
    <div className="App">
      <Router>
        {/* <TopNav login={login} /> */}
        <Routes>
          <Route
            path="/"
            element={
              login === true ? (
                <Dashboard
                  user={user}
                  data={admins.admins}
                  setLogin={setLogin}
                />
              ) : (
                <Home />
              )
            }
          />
          <Route
            path="/transactions"
            element={
              <Transactions setUser={setUser} user={user} setLogin={setLogin} />
            }
          />
          <Route
            path="/investments"
            element={
              <Investments setUser={setUser} user={user} setLogin={setLogin} />
            }
          />
          <Route
            path="/calc"
            element={<InvestmentCalc setLogin={setLogin} />}
          />
          <Route
            path="/login"
            element={<Login setLogin={setLogin} setUser={setUser} />}
          />
          <Route path="/register" element={<Register />} />
        </Routes>
      </Router>
    </div>
  );
}

export default App;

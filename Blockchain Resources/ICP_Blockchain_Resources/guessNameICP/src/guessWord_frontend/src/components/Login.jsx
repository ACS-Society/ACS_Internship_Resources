import React from "react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { guessWord_backend } from "../../../declarations/guessWord_backend/index";

const Login = ({ setLogin, setUser }) => {
  const nav = useNavigate();

  const login = async (e) => {
    e.preventDefault();
    const email = document.getElementById("email");
    const password = document.getElementById("password");

    let userRes = null;
    userRes=await guessWord_backend.getUser(email.value.toString())

    if(userRes.email==""){
      alert("NO USER FOUND!!")
    }else{
      if(userRes.pass==password.value.toString()){
        setLogin(true)
        setUser(userRes)
        alert("Successfully logged in!")
        nav("/")
      }else{
        alert("invalid password!")
      }
    }
  };

  return (
    <div>
      <div className="form-container">
        <form className="form" onSubmit={login}>
          <h1>Login</h1>
          <div className="form-seg">
            <label>Email : </label>
            <input type="email" name="email" id="email" />
          </div>
          <div className="form-seg">
            <label>Password : </label>
            <input type="password" name="password" id="password" />
          </div>
          <p>
            Don't Have an account? Go to the{" "}
            <em
              className="link"
              onClick={() => {
                nav("/register");
              }}
            >
              Register
            </em>{" "}
            page.
          </p>
          <button type="submit" className="submit-btn">
            Login
          </button>
        </form>
      </div>
    </div>
  );
};
export default Login;

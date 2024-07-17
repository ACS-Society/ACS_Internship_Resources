import React from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { expenseTrack_backend } from "../../../declarations/expenseTrack_backend/index";

const Register = () => {
  const nav = useNavigate();
  const register = async (e) => {
    e.preventDefault();
    const email = document.getElementById("email");
    const name = document.getElementById("username");
    const phone = document.getElementById("phone");
    const password = document.getElementById("password");


    const userRes=expenseTrack_backend.getUser(email.value.toString())
    if(userRes.email==""){
      alert("User already exists with this email!")
    }else{
      const user=expenseTrack_backend.createUser(name.value.toString(),email.value.toString(),parseInt(phone.value),password.value.toString())
      console.log(user)
      alert("User added succesfully")
      nav("/login")
    }
    // try {
    //   await axios
    //     .post("https://expense-backend-production-1893.up.railway.app/user", {
    //       name: name.value,
    //       email: email.value,
    //       phone: phone.value,
    //       password: password.value,
    //       transactions: [],
    //       investments: [],
    //     })
    //     .then((res) => {
    //       console.log(res);
    //       alert("User added successfully");
    //       nav("/login");
    //     });
    // } catch (err) {
    //   console.log(err);
    // }
  };
  return (
    <div>
      <div className="form-container">
        <form className="form" onSubmit={register}>
          <h1>Register</h1>
          <div className="form-seg">
            <label>Email : </label>
            <input type="email" name="email" id="email" />
          </div>
          <div className="form-seg">
            <label>Username : </label>
            <input type="text" name="username" id="username" />
          </div>
          <div className="form-seg">
            <label>Phone : </label>
            <input type="number" name="phone" id="phone" />
          </div>
          <div className="form-seg">
            <label>Password : </label>
            <input type="password" name="password" id="password" />
          </div>
          <p>
            Already Have an account? Go to the{" "}
            <em
              className="link"
              onClick={() => {
                nav("/login");
              }}
            >
              login
            </em>{" "}
            page.
          </p>
          <button type="submit" className="submit-btn">
            Register
          </button>
        </form>
      </div>
    </div>
  );
};

export default Register;

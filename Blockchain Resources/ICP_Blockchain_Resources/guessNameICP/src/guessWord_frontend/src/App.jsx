import { BrowserRouter as Router,Routes,Route } from 'react-router-dom';
import { useState } from 'react';
import React from 'react';
import Login from "./components/Login";
import Register from "./components/Register";
import Game from "./components/Game"
import "./App.css"


function App() {
  const [login,setLogin]=useState(false)
  const [user,setUser]=useState({})

  return (
    
      <Router>
        <div className="App">
          
          <Routes>
            <Route path='/login' element={<Login setLogin={setLogin} setUser={setUser}/>}/>
            <Route path='/' element={(login===true)?(<Game setLogin={setLogin} user={user} setUser={setUser}/>):(<Login setLogin={setLogin} setUser={setUser}/>)}/>
            <Route path='/register' element={<Register/>}/>
          </Routes>
        
        </div>

      </Router>
      
      
    
  );
}

export default App;

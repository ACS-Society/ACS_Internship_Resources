import React from 'react'
import {useEffect} from 'react'
import { guessWord_backend } from '../../../declarations/guessWord_backend/index'


const Game = ({setLogin,user,setUser}) => {

  useEffect(()=>{
    

let wordList = [
{
word: "python",
hint: "programming language"
},
{
word: "guitar",
hint: "a musical instrument"
},
{
word: "aim",
hint: "a purpose or intention"
},
{
word: "venus",
hint: "planet of our solar system"
},
{
word: "gold",
hint: "a yellow precious metal"
},
{
word: "ebay",
hint: "online shopping site"
},
{
word: "golang",
hint: "programming language"
},
{
word: "coding",
hint: "related to programming"
},
{

word: "matrix",
hint: "science fiction movie"
},
{
word: "bugs",
hint: "related to programming"
},
{
word: "avatar",
hint: "epic science fiction film"
},
{
word: "gif",
hint: "a file format for image"
},
{
word: "mental",
hint: "related to the mind"
},
{
word: "map",
hint: "diagram represent of an area"
},
{
word: "island",
hint: "land surrounded by water"
},
{
word: "hockey",
hint: "a famous outdoor game"
},
{
word: "chess",
hint: "related to a indoor game"
},
{
word: "viber",
hint: "a social media app"
},
{

word: "github",
hint: "code hosting platform"
},
{
word: "png",
hint: "a image file format"
},
{
word: "silver",
hint: "precious greyish-white metal"
},
{
word: "mobile",
hint: "an electronic device"
},
{
word: "gpu",
hint: "computer component"
},
{
word: "java",
hint: "programming language"
},
{
word: "google",
hint: "famous search engine"
},
{
word: "venice",
hint: "famous city of waters"
},
{
word: "excel",
hint: "microsoft product for windows"
},
{
word: "mysql",
hint: "a relational database system"
},
{

word: "nepal",
hint: "developing country name"
},
{
word: "flute",
hint: "a musical instrument"
},
{
word: "crypto",
hint: "related to cryptocurrency"
},
{
word: "tesla",
hint: "unit of magnetic flux density"
},
{
word: "mars",
hint: "planet of our solar system"
},
{
word: "proxy",
hint: "related to server application"
},
{
word: "email",
hint: "related to exchanging message"
},
{
word: "html",
hint: "markup language for the web"
},
{
word: "air",
hint: "related to a gas"
},
{
word: "idea",
hint: "a thought or suggestion"
},
{

word: "server",
hint: "related to computer or system"
},
{
word: "svg",
hint: "a vector image format"
},
{
word: "jpeg",
hint: "a image file format"
},
{
word: "search",
hint: "act to find something"
},
{
word: "key",
hint: "small piece of metal"
},
{
word: "egypt",
hint: "a country name"
},
{
word: "joker",
hint: "psychological thriller film"
},
{
word: "dubai",
hint: "developed country name"
},
{
word: "photo",
hint: "representation of person or scene"
},
{
word: "nile",
hint: "largest river in the world"
},
{

word: "rain",
hint: "related to a water"
},
]

//document.write(word+hint)
const hintEl=document.getElementById("hint")
const guessLeft=document.getElementById('guesses')
const wrongLetters=document.getElementById('wrong')
const inputCon=document.getElementById('input-container')

function startGame(){
    inputCon.innerHTML=''
    let wordObj=wordList[Math.floor(Math.random()*wordList.length)]
    let word=wordObj.word
    let hint=wordObj.hint
    let guessNum=8
    wrongLetters.innerHTML='Wrong Letters : '
    guessLeft.innerHTML=`Remaining Guesses: ${guessNum}`
    hintEl.innerHTML=`Hint: ${hint}`
    console.log(word)

    for(let i=0;i<word.length;i++){
        let input=document.createElement('input')
        input.type='text'
        input.classList.add('input')
        input.name=word.charAt(i)
        
        inputCon.appendChild(input)
        input.addEventListener('change',()=>{
            if(input.value!=input.name){
                
                wrongLetters.innerHTML+=`${input.value},`
                input.value=''
                guessNum-=1;
                guessLeft.innerHTML=`Remaining Guesses: ${guessNum}`
                if(guessNum==0){
                    endGame(word)
                }
                
                
            }else{
                checkWin(word)
                
            }
        })
    }
}
async function endGame(word){
    for(let i=0;i<word.length;i++){
        let el=document.getElementsByName(word.charAt(i))[0]
        el.removeEventListener('change',()=>{})
        el.value=el.name
    }
    const userNew=await guessWord_backend.upgradeScore(user.name,user.pass,user.email,parseInt(user.wins),parseInt(user.loses)+1)
    setUser(userNew)
    alert(`all your chances are finished correct word is: ${word}, try again`)
    startGame()
}
    async function checkWin(word){
    
    
    let wordNew=''
    for(let i=0;i<word.length;i++){
        wordNew+=document.getElementsByName(word.charAt(i))[0].value
    }
    console.log(wordNew)
    if(word===wordNew){

        const userNew=await guessWord_backend.upgradeScore(user.name,user.pass,user.email,parseInt(user.wins)+1,parseInt(user.loses))
        setUser(userNew)
        alert('congratulations you won!!!'+wordNew)

        startGame()
    }
}
startGame()
  },[])
  
  
  return (
    <div class="game-container">
      
      <h1>Guess the Word</h1>
      <p>
        User : {user.name}<br/><br/>
        Email : {user.email}<br/><br/>
        Number of wins : {parseInt(user.wins)}<br/><br/>
        Number of Loses : {parseInt(user.loses)}<br/><br/>

        Instructions --

        <br />
        don't forget to enter after writing value and go with the sequence only.
        enter in lower case only.<br/>
        hint : You can check the console for right answer
      </p>
      <hr />
      <div id="input-container"></div>
      <p id="hint">Hint:</p>
      <p id="guesses">Remaining Guesses:</p>
      <p id="wrong">Wrong Letters:</p>
      <button class="reset" onClick={()=>startGame()}>Reset Game</button>
      
    </div>
    
  )
}

export default Game
import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

function App() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('http://localhost:8080/api/v1/hello')
      .then(response => response.text())
      .then(body => setData(body))
      .catch(error => console.error(error));
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          {data ? <pre>{data}</pre> : 'Loading...'}
        </p>
      </header>
    </div>
  );
}

export default App;
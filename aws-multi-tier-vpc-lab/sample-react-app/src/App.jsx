import React, { useEffect, useState } from 'react';

function App() {
  const [data, setData] = useState("Loading...");

  useEffect(() => {
    // Calling your internal Load Balancer directly
    fetch('http://44.215.67.63:8000')
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.text(); // or response.json() if your backend sends JSON
      })
      .then(displayText => {
        console.log(displayText);
        setData(displayText);
      })
      .catch(error => {
        console.error('Fetch error:', error);
        setData("Error fetching data. Check console.");
      });
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      <h1>Backend Response:</h1>
      <pre style={{ background: '#f4f4f4', padding: '10px' }}>
        {data}
      </pre>
    </div>
  );
}

export default App;
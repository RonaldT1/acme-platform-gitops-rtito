import { useEffect, useState } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

function App() {
  const [data, setData] = useState(null)

  useEffect(() => {
    fetch(`${API_URL}/api/hello`)
      .then(r => r.json())
      .then(setData)
      .catch(console.error)
  }, [])

  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>Bootcamp App</h1>
      <p>API: {data ? JSON.stringify(data) : 'Loading...'}</p>
    </div>
  )
}

export default App
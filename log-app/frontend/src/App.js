import React, { useState, useEffect } from 'react';
import './App.css';
import LogForm from './components/LogForm';
import LogList from './components/LogList';

function App() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [filter, setFilter] = useState('ALL');

  // Use environment variable or detect current hostname
  const API_URL = process.env.REACT_APP_API_URL || 
                  `http://${window.location.hostname}:5000/api`;

  // Fetch logs
  const fetchLogs = async () => {
    setLoading(true);
    setError(null);
    try {
      const endpoint = filter === 'ALL' 
        ? `${API_URL}/logs` 
        : `${API_URL}/logs/${filter}`;
      
      const response = await fetch(endpoint);
      const data = await response.json();
      
      if (data.success) {
        setLogs(data.data);
      } else {
        setError(data.error || 'Failed to fetch logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  // Create log
  const createLog = async (logData) => {
    try {
      const response = await fetch(`${API_URL}/logs`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(logData),
      });
      
      const data = await response.json();
      
      if (data.success) {
        fetchLogs(); // Refresh the list
        return { success: true };
      } else {
        return { success: false, error: data.error };
      }
    } catch (err) {
      return { success: false, error: 'Error connecting to server: ' + err.message };
    }
  };

  // Delete log
  const deleteLog = async (id) => {
    try {
      const response = await fetch(`${API_URL}/logs/${id}`, {
        method: 'DELETE',
      });
      
      const data = await response.json();
      
      if (data.success) {
        fetchLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to delete log');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  // Clear all logs
  const clearAllLogs = async () => {
    if (!window.confirm('Are you sure you want to clear all logs?')) {
      return;
    }
    
    try {
      const response = await fetch(`${API_URL}/logs`, {
        method: 'DELETE',
      });
      
      const data = await response.json();
      
      if (data.success) {
        fetchLogs(); // Refresh the list
      } else {
        setError(data.error || 'Failed to clear logs');
      }
    } catch (err) {
      setError('Error connecting to server: ' + err.message);
    }
  };

  useEffect(() => {
    fetchLogs();
  }, [filter]);

  return (
    <div className="App">
      <header className="App-header">
        <h1>📝 MariaDB Log Manager</h1>
        <p>React Application for Writing Logs to MariaDB</p>
      </header>

      <main className="App-main">
        <div className="container">
          {/* Log Form Section */}
          <section className="card">
            <h2>Create New Log Entry</h2>
            <LogForm onSubmit={createLog} />
          </section>

          {/* Log List Section */}
          <section className="card">
            <div className="logs-header">
              <h2>Log Entries</h2>
              <div className="controls">
                <select 
                  value={filter} 
                  onChange={(e) => setFilter(e.target.value)}
                  className="filter-select"
                >
                  <option value="ALL">All Levels</option>
                  <option value="DEBUG">DEBUG</option>
                  <option value="INFO">INFO</option>
                  <option value="WARN">WARN</option>
                  <option value="ERROR">ERROR</option>
                  <option value="FATAL">FATAL</option>
                </select>
                <button onClick={fetchLogs} className="btn btn-secondary">
                  🔄 Refresh
                </button>
                <button onClick={clearAllLogs} className="btn btn-danger">
                  🗑️ Clear All
                </button>
              </div>
            </div>

            {error && <div className="error-message">{error}</div>}
            {loading ? (
              <div className="loading">Loading logs...</div>
            ) : (
              <LogList logs={logs} onDelete={deleteLog} />
            )}
          </section>
        </div>
      </main>
    </div>
  );
}

export default App;

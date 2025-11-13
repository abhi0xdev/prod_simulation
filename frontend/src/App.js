import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './index.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

function App() {
  const [items, setItems] = useState([]);
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [status, setStatus] = useState(null);

  useEffect(() => {
    fetchItems();
    // Check API health
    checkHealth();
  }, []);

  const checkHealth = async () => {
    try {
      const response = await axios.get(`${API_URL}/health`);
      setStatus({ type: 'success', message: 'API Connected' });
    } catch (err) {
      setStatus({ type: 'error', message: 'API Connection Failed' });
    }
  };

  const fetchItems = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_URL}/items`);
      setItems(response.data);
    } catch (err) {
      setError('Failed to fetch items: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const createItem = async (e) => {
    e.preventDefault();
    if (!name.trim()) {
      setError('Please enter a name');
      return;
    }

    setLoading(true);
    setError(null);
    try {
      const response = await axios.post(`${API_URL}/items`, { name: name.trim() });
      setItems([...items, response.data]);
      setName('');
      setStatus({ type: 'success', message: 'Item created successfully' });
    } catch (err) {
      setError('Failed to create item: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const deleteItem = async (id) => {
    if (!window.confirm('Are you sure you want to delete this item?')) {
      return;
    }

    setLoading(true);
    setError(null);
    try {
      await axios.delete(`${API_URL}/items/${id}`);
      setItems(items.filter(item => item.id !== id));
      setStatus({ type: 'success', message: 'Item deleted successfully' });
    } catch (err) {
      setError('Failed to delete item: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      <div className="header">
        <h1>Production Simulation App</h1>
        <p>Full-Stack Demo: Frontend → Backend → Database</p>
        {status && (
          <div className={`status status-${status.type}`} style={{ marginTop: '10px', display: 'inline-block' }}>
            {status.message}
          </div>
        )}
      </div>

      <div className="form-section">
        <h2>Create New Item</h2>
        <form onSubmit={createItem}>
          <div className="form-group">
            <label htmlFor="name">Name:</label>
            <input
              type="text"
              id="name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter item name"
              disabled={loading}
            />
          </div>
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? 'Creating...' : 'Create Item'}
          </button>
        </form>
        {error && <div className="status status-error" style={{ marginTop: '10px' }}>{error}</div>}
      </div>

      <div className="items-section">
        <h2>Items ({items.length})</h2>
        {loading && items.length === 0 ? (
          <div className="loading">Loading items...</div>
        ) : items.length === 0 ? (
          <div className="loading">No items yet. Create one above!</div>
        ) : (
          <div className="items-list">
            {items.map(item => (
              <div key={item.id} className="item-card">
                <div className="item-info">
                  <div className="item-name">{item.name}</div>
                  <div className="item-timestamp">
                    Created: {new Date(item.created_at).toLocaleString()}
                  </div>
                </div>
                <button
                  className="btn btn-danger"
                  onClick={() => deleteItem(item.id)}
                  disabled={loading}
                >
                  Delete
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default App;


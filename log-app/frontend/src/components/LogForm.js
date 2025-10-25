import React, { useState } from 'react';

function LogForm({ onSubmit }) {
  const [formData, setFormData] = useState({
    message: '',
    source: ''
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    // Validate
    if (!formData.message.trim()) {
      setError('Message is required');
      setLoading(false);
      return;
    }

    const logData = {
      message: formData.message,
      source: formData.source || undefined
    };

    const result = await onSubmit(logData);
    setLoading(false);

    if (result.success) {
      setSuccess('Log entry created successfully!');
      // Reset form
      setFormData({
        message: '',
        source: ''
      });
      setTimeout(() => setSuccess(''), 3000);
    } else {
      setError(result.error || 'Failed to create log entry');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="log-form">
      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}

      <div className="form-group">
        <label htmlFor="message">Command *</label>
        <textarea
          id="message"
          name="message"
          value={formData.message}
          onChange={handleChange}
          className="form-control"
          rows="3"
          placeholder="Enter log message..."
          required
        />
      </div>

      <div className="form-group">
        <label htmlFor="source">Source(ignore for now)</label>
        <input
          type="text"
          id="source"
          name="source"
          value={formData.source}
          onChange={handleChange}
          className="form-control"
          placeholder="e.g., UserService, AuthController"
        />
      </div>

      <button type="submit" className="btn btn-primary" disabled={loading}>
        {loading ? 'Creating...' : '✓ Create Log Entry'}
      </button>
    </form>
  );
}

export default LogForm;

import React, { useState } from 'react';

function LogForm({ onSubmit }) {
  const [formData, setFormData] = useState({
    message: '',
    source: '',
    metadata: ''
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

    // Parse metadata if provided
    let metadata = {};
    if (formData.metadata.trim()) {
      try {
        metadata = JSON.parse(formData.metadata);
      } catch (err) {
        setError('Invalid JSON in metadata field');
        setLoading(false);
        return;
      }
    }

    const logData = {
      message: formData.message,
      source: formData.source || undefined,
      metadata: Object.keys(metadata).length > 0 ? metadata : undefined
    };

    const result = await onSubmit(logData);
    setLoading(false);

    if (result.success) {
      setSuccess('Log entry created successfully!');
      // Reset form
      setFormData({
        message: '',
        source: '',
        metadata: ''
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
        <label htmlFor="message">Message *</label>
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
        <label htmlFor="source">Source</label>
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

      <div className="form-group">
        <label htmlFor="metadata">Metadata (JSON)</label>
        <textarea
          id="metadata"
          name="metadata"
          value={formData.metadata}
          onChange={handleChange}
          className="form-control"
          rows="2"
          placeholder='{"userId": 123, "action": "login"}'
        />
      </div>

      <button type="submit" className="btn btn-primary" disabled={loading}>
        {loading ? 'Creating...' : '✓ Create Log Entry'}
      </button>
    </form>
  );
}

export default LogForm;
